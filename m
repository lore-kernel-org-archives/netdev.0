From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 3/3] [CCID3]: HC-receiver should not insert timestamps as HC-sender doesn't uses it
Date: Sat,  8 Dec 2007 16:52:13 -0200
Message-ID: <1197139933-11609-4-git-send-email-acme@redhat.com>
References: <1197139933-11609-1-git-send-email-acme@redhat.com>
 <1197139933-11609-2-git-send-email-acme@redhat.com>
 <1197139933-11609-3-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:9925 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbXLHS6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 13:58:08 -0500
Received: by an-out-0708.google.com with SMTP id d31so285063and
        for <netdev@vger.kernel.org>; Sat, 08 Dec 2007 10:58:07 -0800 (PST)
In-Reply-To: <1197139933-11609-3-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a5246f7..60fcb31 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -750,8 +750,7 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
 
-	if (dccp_insert_option_timestamp(sk, skb) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
 			       &x_recv, sizeof(x_recv)))
-- 
1.5.3.4

