From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 7/10] hostap: Rate limiting for debug messages
Date: Sat, 12 Mar 2005 16:34:12 -0800
Message-ID: <20050313003412.GH8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Limit rate of debug messages for interrupts before card is ready. This
could happen when multiple devices are sharing the same interrupt.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_hw.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_hw.c	2005-03-12 16:10:40.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_hw.c	2005-03-12 16:10:58.000000000 -0800
@@ -2790,8 +2790,10 @@
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INTERRUPT, 0, 0);
 
 	if (local->func->card_present && !local->func->card_present(local)) {
-		printk(KERN_DEBUG "%s: Interrupt, but dev not OK\n",
-		       dev->name);
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: Interrupt, but dev not OK\n",
+			       dev->name);
+		}
 		return IRQ_HANDLED;
 	}
 

-- 
Jouni Malinen                                            PGP id EFC895FA
