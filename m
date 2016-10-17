From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH v5 1/4] skge: Rename LED_OFF and LED_ON in marvel skge driver
 to avoid conflicts with leds namespace
Date: Mon, 17 Oct 2016 10:49:52 -0500
Message-ID: <1476719395-28273-2-git-send-email-zach.brown@ni.com>
References: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 andrew@lunn.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 rpurdie@rpsys.net, gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net,
 j.anaszewski@samsung.com, linux-leds@vger.kernel.org, mlindner@marvell.com
To: <f.fainelli@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
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
Also changed LED_ON to LED_REG_ON to avoid possible future conflict and
for consistency.

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/ethernet/marvell/skge.c | 6 +++---
 drivers/net/ethernet/marvell/skge.h | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 7173836..783df01 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -1048,7 +1048,7 @@ static const char *skge_pause(enum pause_status status)
 static void skge_link_up(struct skge_port *skge)
 {
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG),
-		    LED_BLK_OFF|LED_SYNC_OFF|LED_ON);
+		    LED_BLK_OFF|LED_SYNC_OFF|LED_REG_ON);
 
 	netif_carrier_on(skge->netdev);
 	netif_wake_queue(skge->netdev);
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
index a2eb341..3ea151f 100644
--- a/drivers/net/ethernet/marvell/skge.h
+++ b/drivers/net/ethernet/marvell/skge.h
@@ -662,8 +662,8 @@ enum {
 	LED_BLK_OFF	= 1<<4,	/* Link LED Blinking Off */
 	LED_SYNC_ON	= 1<<3,	/* Use Sync Wire to switch LED */
 	LED_SYNC_OFF	= 1<<2,	/* Disable Sync Wire Input */
-	LED_ON	= 1<<1,	/* switch LED on */
-	LED_OFF	= 1<<0,	/* switch LED off */
+	LED_REG_ON	= 1<<1,	/* switch LED on */
+	LED_REG_OFF	= 1<<0,	/* switch LED off */
 };
 
 /* Receive GMAC FIFO (YUKON) */
-- 
2.7.4
