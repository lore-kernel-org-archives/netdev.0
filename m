From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netpoll: don't send packets to detached device
Date: Wed, 18 Oct 2006 13:50:33 -0700
Message-ID: <20061018135033.4a4872b8@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2230 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751505AbWJRUwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 16:52:01 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netpoll shouldn't send packets to devices that have detached themselves.
This can happen during shutdown or suspend.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- a/net/core/netpoll.c	2006-10-18 13:41:49.000000000 -0700
+++ b/net/core/netpoll.c	2006-10-18 13:43:44.000000000 -0700
@@ -273,7 +273,7 @@
 	int status;
 	struct netpoll_info *npinfo;
 
-	if (!np || !np->dev || !netif_running(np->dev)) {
+	if (!np || !np->dev || !netif_device_present(np->dev) || !netif_running(np->dev)) {
 		__kfree_skb(skb);
 		return;
 	}
