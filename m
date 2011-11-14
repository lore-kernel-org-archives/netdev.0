From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: fix a memory leak in ic_bootp_send_if
Date: Mon, 14 Nov 2011 15:54:08 +0800
Message-ID: <1321257248-14175-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44556 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab1KNHyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 02:54:16 -0500
Received: by iage36 with SMTP id e36so6935221iag.19
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 23:54:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

when dev_hard_header() failed, the newly allocated skb should be freed.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv4/ipconfig.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 0da2afc..7f17ba8 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -822,8 +822,13 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 	if (dev_hard_header(skb, dev, ntohs(skb->protocol),
-			    dev->broadcast, dev->dev_addr, skb->len) < 0 ||
-	    dev_queue_xmit(skb) < 0)
+			    dev->broadcast, dev->dev_addr, skb->len) < 0) {
+		kfree_skb(skb);
+		printk("E");
+		return;
+	}
+
+	if (dev_queue_xmit(skb) < 0)
 		printk("E");
 }
 
-- 
1.7.1
