From: Lightweight patch manager <patch@luckynet.dynu.com>
Subject: [PATCH][2.5] list_move_tail for network core (1 occ)
Date: Sun, 9 Jun 2002 09:02:43 -0600 (MDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <advqr3$drk$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Team <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Linux Network <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

This uses the newly introduced list_move_tail macro in net/core/dev.c

--- linus-2.5/net/core/dev.c	Sun Jun  9 04:17:32 2002
+++ thunder-2.5/net/core/dev.c	Sun Jun  9 07:41:55 2002
@@ -1596,8 +1596,7 @@
 
 		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
 			local_irq_disable();
-			list_del(&dev->poll_list);
-			list_add_tail(&dev->poll_list, &queue->poll_list);
+			list_move_tail(&dev->poll_list, &queue->poll_list);
 			if (dev->quota < 0)
 				dev->quota += dev->weight;
 			else

-- 
Lightweight patch manager using pine. If you have any objections, tell me.
