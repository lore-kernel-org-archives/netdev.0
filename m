From: Florin Malita <fmalita@gmail.com>
Subject: [PATCH] spidernet: skb used after netif_receive_skb
Date: Wed, 16 May 2007 21:39:31 -0400
Message-ID: <464BB253.7080406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:47367 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757106AbXEQBlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 21:41:09 -0400
Received: by an-out-0708.google.com with SMTP id d18so90856and
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 18:41:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The stats update code in spider_net_pass_skb_up() is touching the skb 
after it's been passed up to the stack. To avoid that, just update the 
stats first.


Signed-off-by: Florin Malita <fmalita@gmail.com>
---

 spider_net.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 108adbf..1df2f0b 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1013,12 +1013,12 @@ spider_net_pass_skb_up(struct spider_net_descr *descr,
 		 */
 	}
 
-	/* pass skb up to stack */
-	netif_receive_skb(skb);
-
 	/* update netdevice statistics */
 	card->netdev_stats.rx_packets++;
 	card->netdev_stats.rx_bytes += skb->len;
+
+	/* pass skb up to stack */
+	netif_receive_skb(skb);
 }
 
 #ifdef DEBUG

