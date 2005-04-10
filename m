From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH] 3c574_cs: disable interrupts in el3_close
Date: Sun, 10 Apr 2005 20:27:45 +0200
Message-ID: <200504102027.45729.daniel.ritz@gmx.ch>
Reply-To: daniel.ritz@gmx.ch
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

3c574_cs forgets to disable interrupts during el3_close().
fix it by doing what 3c59x does.

Signed-off-by: Daniel Ritz <daniel.ritz@gmx.ch>

--- 1.40/drivers/net/pcmcia/3c574_cs.c	2005-01-25 22:50:25 +01:00
+++ edited/drivers/net/pcmcia/3c574_cs.c	2005-04-09 21:49:02 +02:00
@@ -1274,6 +1274,9 @@
 		spin_lock_irqsave(&lp->window_lock, flags);
 		update_stats(dev);
 		spin_unlock_irqrestore(&lp->window_lock, flags);
+
+		/* force interrupts off */
+		outw(SetIntrEnb | 0x0000, ioaddr + EL3_CMD);
 	}
 
 	link->open--;
