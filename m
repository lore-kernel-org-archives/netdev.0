From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net/at91_ether: use gpio_to_irq for phy IRQ line
Date: Mon, 23 Apr 2012 11:37:32 +0200
Message-ID: <1335173852-582-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <plagnioj@jcrosoft.com>, <avictor.za@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the gpio_to_irq() function to retrieve the phy IRQ line
from the GPIO pin specification.
This fix is needed now that we have moved to irqdomains on AT91.

Reported-by: Jamie Iles <jamie@jamieiles.com>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Cc: Andrew Victor <avictor.za@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/cadence/at91_ether.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 9061170..236d708 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -265,7 +265,7 @@ static void enable_phyirq(struct net_device *dev)
 		return;
 	}
 
-	irq_number = lp->board_data.phy_irq_pin;
+	irq_number = gpio_to_irq(lp->board_data.phy_irq_pin);
 	status = request_irq(irq_number, at91ether_phy_interrupt, 0, dev->name, dev);
 	if (status) {
 		printk(KERN_ERR "at91_ether: PHY IRQ %d request failed - status %d!\n", irq_number, status);
@@ -365,7 +365,7 @@ static void disable_phyirq(struct net_device *dev)
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
 
-	irq_number = lp->board_data.phy_irq_pin;
+	irq_number = gpio_to_irq(lp->board_data.phy_irq_pin);
 	free_irq(irq_number, dev);			/* Free interrupt handler */
 }
 
@@ -1193,7 +1193,7 @@ static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
 
 	if (netif_running(net_dev)) {
 		if (gpio_is_valid(lp->board_data.phy_irq_pin)) {
-			int phy_irq = lp->board_data.phy_irq_pin;
+			int phy_irq = gpio_to_irq(lp->board_data.phy_irq_pin);
 			disable_irq(phy_irq);
 		}
 
@@ -1217,7 +1217,7 @@ static int at91ether_resume(struct platform_device *pdev)
 		netif_start_queue(net_dev);
 
 		if (gpio_is_valid(lp->board_data.phy_irq_pin)) {
-			int phy_irq = lp->board_data.phy_irq_pin;
+			int phy_irq = gpio_to_irq(lp->board_data.phy_irq_pin);
 			enable_irq(phy_irq);
 		}
 	}
-- 
1.7.10
