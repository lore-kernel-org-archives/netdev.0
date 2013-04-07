From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 01/16] atm: update msg_namelen in vcc_recvmsg()
Date: Sun,  7 Apr 2013 13:51:47 +0200
Message-ID: <1365335522-29931-2-git-send-email-minipli@googlemail.com>
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
Received: from mail-bk0-f48.google.com ([209.85.214.48]:63662 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933435Ab3DGLwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:25 -0400
Received: by mail-bk0-f48.google.com with SMTP id jf3so2711947bkc.35
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:24 -0700 (PDT)
In-Reply-To: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code does not fill the msg_name member in case it is set.
It also does not set the msg_namelen member to 0 and therefore makes
net/socket.c leak the local, uninitialized sockaddr_storage variable
to userland -- 128 bytes of kernel stack memory.

Fix that by simply setting msg_namelen to 0 as obviously nobody cared
about vcc_recvmsg() not filling the msg_name in case it was set.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/atm/common.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/atm/common.c b/net/atm/common.c
index 7b49100..737bef5 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -531,6 +531,8 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	struct sk_buff *skb;
 	int copied, error = -EINVAL;
 
+	msg->msg_namelen = 0;
+
 	if (sock->state != SS_CONNECTED)
 		return -ENOTCONN;
 
-- 
1.7.10.4
