From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 09/16] l2tp: fix info leak in l2tp_ip6_recvmsg()
Date: Sun,  7 Apr 2013 13:51:55 +0200
Message-ID: <1365335522-29931-10-git-send-email-minipli@googlemail.com>
References: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Andy King <acking@vmware.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Brad Spengler <spender@grsecurity.net>,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:61228 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933504Ab3DGLwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:35 -0400
Received: by mail-bk0-f42.google.com with SMTP id jc3so2710234bkc.1
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:34 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The L2TP code for IPv6 fails to initialize the l2tp_conn_id member of
struct sockaddr_l2tpip6 and therefore leaks four bytes kernel stack
in l2tp_ip6_recvmsg() in case msg_name is set.

Initialize l2tp_conn_id with 0 to avoid the info leak.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/l2tp/l2tp_ip6.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index c74f5a9..b8a6039 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -690,6 +690,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		lsa->l2tp_addr = ipv6_hdr(skb)->saddr;
 		lsa->l2tp_flowinfo = 0;
 		lsa->l2tp_scope_id = 0;
+		lsa->l2tp_conn_id = 0;
 		if (ipv6_addr_type(&lsa->l2tp_addr) & IPV6_ADDR_LINKLOCAL)
 			lsa->l2tp_scope_id = IP6CB(skb)->iif;
 	}
-- 
1.7.10.4
