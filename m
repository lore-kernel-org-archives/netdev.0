From: Zach Brown <zach.brown@ni.com>
Subject: [RFC 1/3] skge: Change LED_OFF to LED_REG_OFF in marvel skge driver
 to avoid conflicts with leds namespace
Date: Wed, 14 Sep 2016 16:55:47 -0500
Message-ID: <1473890149-2066-2-git-send-email-zach.brown@ni.com>
References: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Larry.Finger@lwfinger.net, mlindner@marvell.com
To: f.fainelli@gmail.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Adding led support for phy causes namespace conflicts for some
phy drivers.

The marvel skge driver declared an enum for representing the states of
Link LED Register. The enum contained constant LED_OFF which conflicted
with declartation found in linux/leds.h.
LED_OFF changed to LED_REG_OFF

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/ethernet/marvell/skge.c | 4 ++--
 drivers/net/ethernet/marvell/skge.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 7173836..ff5a087 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -1062,7 +1062,7 @@ static void skge_link_up(struct skge_port *skge)
 
 static void skge_link_down(struct skge_port *skge)
 {
-	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
+	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_REG_OFF);
 	netif_carrier_off(skge->netdev);
 	netif_stop_queue(skge->netdev);
 
@@ -2668,7 +2668,7 @@ static int skge_down(struct net_device *dev)
 	if (hw->ports == 1)
 		free_irq(hw->pdev->irq, hw);
 
-	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
+	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_REG_OFF);
 	if (is_genesis(hw))
 		genesis_stop(skge);
 	else
diff --git a/drivers/net/ethernet/marvell/skge.h b/drivers/net/ethernet/marvell/skge.h
index a2eb341..ec054d3 100644
--- a/drivers/net/ethernet/marvell/skge.h
+++ b/drivers/net/ethernet/marvell/skge.h
@@ -663,7 +663,7 @@ enum {
 	LED_SYNC_ON	= 1<<3,	/* Use Sync Wire to switch LED */
 	LED_SYNC_OFF	= 1<<2,	/* Disable Sync Wire Input */
 	LED_ON	= 1<<1,	/* switch LED on */
-	LED_OFF	= 1<<0,	/* switch LED off */
+	LED_REG_OFF	= 1<<0,	/* switch LED off */
 };
 
 /* Receive GMAC FIFO (YUKON) */
-- 
2.7.4
