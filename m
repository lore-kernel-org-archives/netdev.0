From: jamesm@samba.org
Subject: [PATCH][TG3] fix tx timeout after setting mtu
Date: Sun, 20 Apr 2003 16:40:42 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0304201632010.3657-100000@dp.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch against recent bk stops a tx timeout when setting the mtu.

- James
-- 
James Morris
<jamesm@samba.org>

--- bk.orig/drivers/net/tg3.c	Thu Apr 10 08:37:14 2003
+++ bk.w1/drivers/net/tg3.c	Mon Apr 21 02:22:48 2003
@@ -2769,6 +2769,7 @@
 	tg3_init_rings(tp);
 	tg3_init_hw(tp);
 
+	netif_wake_queue(tp->dev);
 	spin_unlock(&tp->tx_lock);
 	spin_unlock_irq(&tp->lock);
 	tg3_netif_start(tp);
