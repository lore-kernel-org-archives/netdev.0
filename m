From: davej@codemonkey.org.uk
Subject: missing netrom patch in 2.5
Date: Thu, 15 May 2003 04:31:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305150331.h4F3VESL000719@deviant.impure.org.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This went into 2.4 a year back in 2.4.19pre1-pre2,
and is still missing in current 2.5

diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/netrom/nr_loopback.c linux-2.5/net/netrom/nr_loopback.c
--- bk-linus/net/netrom/nr_loopback.c	2003-04-10 06:01:43.000000000 +0100
+++ linux-2.5/net/netrom/nr_loopback.c	2003-03-17 23:43:10.000000000 +0000
@@ -76,6 +76,9 @@ static void nr_loopback_timer(unsigned l
 		if (dev == NULL || nr_rx_frame(skb, dev) == 0)
 			kfree_skb(skb);
 
+		if (dev != NULL)
+			dev_put(dev);
+
 		if (!skb_queue_empty(&loopback_queue) && !nr_loopback_running())
 			nr_set_loopback_timer();
 	}
