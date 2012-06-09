From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] phy: Use pr_<level>
Date: Sat, 09 Jun 2012 10:49:07 -0700
Message-ID: <1339264147.5848.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41436 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752177Ab2FIRtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 13:49:08 -0400
Received: from [96.251.11.108] (account joe@perches.com HELO [192.168.1.162])
  by labridge.com (CommuniGate Pro SMTP 5.0.14)
  with ESMTPA id 19244394 for netdev@vger.kernel.org; Sat, 09 Jun 2012 10:49:08 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a more current logging style.

Add pr_fmt and missing newlines.
Remove embedded prefixes.
Neaten phy_print_status to avoid using KERN_CONT.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/phy/dp83640.c    |   23 +++++++++++++----------
 drivers/net/phy/fixed.c      |    4 ++--
 drivers/net/phy/mdio_bus.c   |    5 ++++-
 drivers/net/phy/national.c   |    8 ++++++--
 drivers/net/phy/phy.c        |   35 +++++++++++++++++------------------
 drivers/net/phy/phy_device.c |    7 +++++--
 drivers/net/phy/spi_ks8995.c |    4 +++-
 7 files changed, 50 insertions(+), 36 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 940b290..b0da022 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -17,6 +17,9 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/ethtool.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
@@ -453,16 +456,16 @@ static void enable_status_frames(struct phy_device *phydev, bool on)
 	ext_write(0, phydev, PAGE6, PSF_CFG1, ver);
 
 	if (!phydev->attached_dev) {
-		pr_warning("dp83640: expected to find an attached netdevice\n");
+		pr_warn("expected to find an attached netdevice\n");
 		return;
 	}
 
 	if (on) {
 		if (dev_mc_add(phydev->attached_dev, status_frame_dst))
-			pr_warning("dp83640: failed to add mc address\n");
+			pr_warn("failed to add mc address\n");
 	} else {
 		if (dev_mc_del(phydev->attached_dev, status_frame_dst))
-			pr_warning("dp83640: failed to delete mc address\n");
+			pr_warn("failed to delete mc address\n");
 	}
 }
 
@@ -582,9 +585,9 @@ static void recalibrate(struct dp83640_clock *clock)
 	 * read out and correct offsets
 	 */
 	val = ext_read(master, PAGE4, PTP_STS);
-	pr_info("master PTP_STS  0x%04hx", val);
+	pr_info("master PTP_STS  0x%04hx\n", val);
 	val = ext_read(master, PAGE4, PTP_ESTS);
-	pr_info("master PTP_ESTS 0x%04hx", val);
+	pr_info("master PTP_ESTS 0x%04hx\n", val);
 	event_ts.ns_lo  = ext_read(master, PAGE4, PTP_EDATA);
 	event_ts.ns_hi  = ext_read(master, PAGE4, PTP_EDATA);
 	event_ts.sec_lo = ext_read(master, PAGE4, PTP_EDATA);
@@ -594,9 +597,9 @@ static void recalibrate(struct dp83640_clock *clock)
 	list_for_each(this, &clock->phylist) {
 		tmp = list_entry(this, struct dp83640_private, list);
 		val = ext_read(tmp->phydev, PAGE4, PTP_STS);
-		pr_info("slave  PTP_STS  0x%04hx", val);
+		pr_info("slave  PTP_STS  0x%04hx\n", val);
 		val = ext_read(tmp->phydev, PAGE4, PTP_ESTS);
-		pr_info("slave  PTP_ESTS 0x%04hx", val);
+		pr_info("slave  PTP_ESTS 0x%04hx\n", val);
 		event_ts.ns_lo  = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
 		event_ts.ns_hi  = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
 		event_ts.sec_lo = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
@@ -686,7 +689,7 @@ static void decode_rxts(struct dp83640_private *dp83640,
 	prune_rx_ts(dp83640);
 
 	if (list_empty(&dp83640->rxpool)) {
-		pr_debug("dp83640: rx timestamp pool is empty\n");
+		pr_debug("rx timestamp pool is empty\n");
 		goto out;
 	}
 	rxts = list_first_entry(&dp83640->rxpool, struct rxts, list);
@@ -709,7 +712,7 @@ static void decode_txts(struct dp83640_private *dp83640,
 	skb = skb_dequeue(&dp83640->tx_queue);
 
 	if (!skb) {
-		pr_debug("dp83640: have timestamp but tx_queue empty\n");
+		pr_debug("have timestamp but tx_queue empty\n");
 		return;
 	}
 	ns = phy2txts(phy_txts);
@@ -847,7 +850,7 @@ static void dp83640_free_clocks(void)
 	list_for_each_safe(this, next, &phyter_clocks) {
 		clock = list_entry(this, struct dp83640_clock, list);
 		if (!list_empty(&clock->phylist)) {
-			pr_warning("phy list non-empty while unloading");
+			pr_warn("phy list non-empty while unloading\n");
 			BUG();
 		}
 		list_del(&clock->list);
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 633680d..ba55adf 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -70,7 +70,7 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 			lpa |= LPA_10FULL;
 			break;
 		default:
-			printk(KERN_WARNING "fixed phy: unknown speed\n");
+			pr_warn("fixed phy: unknown speed\n");
 			return -EINVAL;
 		}
 	} else {
@@ -90,7 +90,7 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
 			lpa |= LPA_10HALF;
 			break;
 		default:
-			printk(KERN_WARNING "fixed phy: unknown speed\n");
+			pr_warn("fixed phy: unknown speed\n");
 			return -EINVAL;
 		}
 	}
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 683ef1c..d4a4992 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -13,6 +13,9 @@
  * option) any later version.
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -148,7 +151,7 @@ int mdiobus_register(struct mii_bus *bus)
 
 	err = device_register(&bus->dev);
 	if (err) {
-		printk(KERN_ERR "mii_bus %s failed to register\n", bus->id);
+		pr_err("mii_bus %s failed to register\n", bus->id);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
index 04bb8fc..9a5f234 100644
--- a/drivers/net/phy/national.c
+++ b/drivers/net/phy/national.c
@@ -15,6 +15,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mii.h>
@@ -22,6 +24,8 @@
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 
+#define DEBUG
+
 /* DP83865 phy identifier values */
 #define DP83865_PHY_ID	0x20005c7a
 
@@ -112,8 +116,8 @@ static void ns_10_base_t_hdx_loopack(struct phy_device *phydev, int disable)
 		ns_exp_write(phydev, 0x1c0,
 			     ns_exp_read(phydev, 0x1c0) & 0xfffe);
 
-	printk(KERN_DEBUG "DP83865 PHY: 10BASE-T HDX loopback %s\n",
-	       (ns_exp_read(phydev, 0x1c0) & 0x0001) ? "off" : "on");
+	pr_debug("10BASE-T HDX loopback %s\n",
+		 (ns_exp_read(phydev, 0x1c0) & 0x0001) ? "off" : "on");
 }
 
 static int ns_config_init(struct phy_device *phydev)
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3cbda08..2e1c237 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -15,6 +15,9 @@
  * option) any later version.
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -44,18 +47,16 @@
  */
 void phy_print_status(struct phy_device *phydev)
 {
-	pr_info("PHY: %s - Link is %s", dev_name(&phydev->dev),
-			phydev->link ? "Up" : "Down");
 	if (phydev->link)
-		printk(KERN_CONT " - %d/%s", phydev->speed,
-				DUPLEX_FULL == phydev->duplex ?
-				"Full" : "Half");
-
-	printk(KERN_CONT "\n");
+		pr_info("%s - Link is Up - %d/%s\n",
+			dev_name(&phydev->dev),
+			phydev->speed,
+			DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
+	else
+		pr_info("%s - Link is Down\n", dev_name(&phydev->dev));
 }
 EXPORT_SYMBOL(phy_print_status);
 
-
 /**
  * phy_clear_interrupt - Ack the phy device's interrupt
  * @phydev: the phy_device struct
@@ -482,9 +483,8 @@ static void phy_force_reduction(struct phy_device *phydev)
 	phydev->speed = settings[idx].speed;
 	phydev->duplex = settings[idx].duplex;
 
-	pr_info("Trying %d/%s\n", phydev->speed,
-			DUPLEX_FULL == phydev->duplex ?
-			"FULL" : "HALF");
+	pr_info("Trying %d/%s\n",
+		phydev->speed, DUPLEX_FULL == phydev->duplex ? "FULL" : "HALF");
 }
 
 
@@ -598,9 +598,8 @@ int phy_start_interrupts(struct phy_device *phydev)
 				IRQF_SHARED,
 				"phy_interrupt",
 				phydev) < 0) {
-		printk(KERN_WARNING "%s: Can't get IRQ %d (PHY)\n",
-				phydev->bus->name,
-				phydev->irq);
+		pr_warn("%s: Can't get IRQ %d (PHY)\n",
+			phydev->bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
 		return 0;
 	}
@@ -838,10 +837,10 @@ void phy_state_machine(struct work_struct *work)
 
 				phydev->autoneg = AUTONEG_DISABLE;
 
-				pr_info("Trying %d/%s\n", phydev->speed,
-						DUPLEX_FULL ==
-						phydev->duplex ?
-						"FULL" : "HALF");
+				pr_info("Trying %d/%s\n",
+					phydev->speed,
+					DUPLEX_FULL == phydev->duplex ?
+					"FULL" : "HALF");
 			}
 			break;
 		case PHY_NOLINK:
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index de86a55..18ab0da 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -14,6 +14,9 @@
  * option) any later version.
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -975,8 +978,8 @@ int phy_driver_register(struct phy_driver *new_driver)
 	retval = driver_register(&new_driver->driver);
 
 	if (retval) {
-		printk(KERN_ERR "%s: Error %d in registering driver\n",
-				new_driver->name, retval);
+		pr_err("%s: Error %d in registering driver\n",
+		       new_driver->name, retval);
 
 		return retval;
 	}
diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 4eb98bc..1c3abce 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -11,6 +11,8 @@
  * by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -356,7 +358,7 @@ static struct spi_driver ks8995_driver = {
 
 static int __init ks8995_init(void)
 {
-	printk(KERN_INFO DRV_DESC " version " DRV_VERSION"\n");
+	pr_info(DRV_DESC " version " DRV_VERSION "\n");
 
 	return spi_register_driver(&ks8995_driver);
 }
