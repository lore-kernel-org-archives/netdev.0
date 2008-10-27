From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.28-rc2] at91_ether:  request/free GPIO for PHY interrupt
Date: Mon, 27 Oct 2008 14:11:34 -0700
Message-ID: <200810271411.34492.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Victor <linux@maxim.org.za>, Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:42639 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752323AbYJ0ViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 17:38:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

When the at91_ether driver is using a GPIO for its PHY interrupt,
be sure to request (and later, if needed, free) that GPIO.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/arm/at91_ether.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -1080,7 +1080,8 @@ static int __init at91ether_setup(unsign
 		init_timer(&lp->check_timer);
 		lp->check_timer.data = (unsigned long)dev;
 		lp->check_timer.function = at91ether_check_link;
-	}
+	} else if (lp->board_data.phy_irq_pin >= 32)
+		gpio_request(lp->board_data.phy_irq_pin, "ethernet_phy");
 
 	/* Display ethernet banner */
 	printk(KERN_INFO "%s: AT91 ethernet at 0x%08x int=%d %s%s (%s)\n",
@@ -1167,6 +1168,9 @@ static int __devexit at91ether_remove(st
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct at91_private *lp = netdev_priv(dev);
 
+	if (lp->board_data.phy_irq_pin >= 32)
+		gpio_free(lp->board_data.phy_irq_pin);
+
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
