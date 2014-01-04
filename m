From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 4/6] phy: kill excess code
Date: Sat, 4 Jan 2014 04:19:14 +0300
Message-ID: <201401040419.14818.sergei.shtylyov@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:57261 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbaADATM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:19:12 -0500
Received: by mail-la0-f44.google.com with SMTP id e16so604634lan.3
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:19:11 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-83-104.pppoe.mtu-net.ru. [91.76.83.104])
        by mx.google.com with ESMTPSA id rb4sm37497807lbb.1.2014.01.03.16.19.10
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 16:19:10 -0800 (PST)
In-Reply-To: <201401040413.06853.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove tens of lines of unnecessary code:

- kill empty lines between a function call and its result check;

- convert assignments to initializers;

- kill useless assignments before *return*;

- kill excess empty lines.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/phy.c        |   31 ++++------------------------
 drivers/net/phy/phy_device.c |   46 +++++++------------------------------------
 2 files changed, 13 insertions(+), 64 deletions(-)

Index: net-next/drivers/net/phy/phy.c
===================================================================
--- net-next.orig/drivers/net/phy/phy.c
+++ net-next/drivers/net/phy/phy.c
@@ -100,9 +100,7 @@ static int phy_config_interrupt(struct p
  */
 static inline int phy_aneg_done(struct phy_device *phydev)
 {
-	int retval;
-
-	retval = phy_read(phydev, MII_BMSR);
+	int retval = phy_read(phydev, MII_BMSR);
 
 	return (retval < 0) ? retval : (retval & BMSR_ANEGCOMPLETE);
 }
@@ -386,7 +384,6 @@ int phy_start_aneg(struct phy_device *ph
 		phy_sanitize_settings(phydev);
 
 	err = phydev->drv->config_aneg(phydev);
-
 	if (err < 0)
 		goto out_unlock;
 
@@ -406,7 +403,6 @@ out_unlock:
 }
 EXPORT_SYMBOL(phy_start_aneg);
 
-
 /**
  * phy_start_machine - start PHY state machine tracking
  * @phydev: the phy_device struct
@@ -498,16 +494,12 @@ static irqreturn_t phy_interrupt(int irq
  */
 static int phy_enable_interrupts(struct phy_device *phydev)
 {
-	int err;
-
-	err = phy_clear_interrupt(phydev);
+	int err = phy_clear_interrupt(phydev);
 
 	if (err < 0)
 		return err;
 
-	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
-
-	return err;
+	return phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
 }
 
 /**
@@ -571,9 +563,7 @@ EXPORT_SYMBOL(phy_start_interrupts);
  */
 int phy_stop_interrupts(struct phy_device *phydev)
 {
-	int err;
-
-	err = phy_disable_interrupts(phydev);
+	int err = phy_disable_interrupts(phydev);
 
 	if (err)
 		phy_error(phydev);
@@ -597,7 +587,6 @@ int phy_stop_interrupts(struct phy_devic
 }
 EXPORT_SYMBOL(phy_stop_interrupts);
 
-
 /**
  * phy_change - Scheduled by the phy_interrupt/timer to handle PHY changes
  * @work: work_struct that describes the work to be done
@@ -630,7 +619,6 @@ void phy_change(struct work_struct *work
 	/* reschedule state queue work to run as soon as possible */
 	cancel_delayed_work_sync(&phydev->state_queue);
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
-
 	return;
 
 ignore:
@@ -676,7 +664,6 @@ out_unlock:
 }
 EXPORT_SYMBOL(phy_stop);
 
-
 /**
  * phy_start - start or restart a PHY device
  * @phydev: target phy_device struct
@@ -738,7 +725,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_AN:
 		err = phy_read_status(phydev);
-
 		if (err < 0)
 			break;
 
@@ -770,7 +756,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_NOLINK:
 		err = phy_read_status(phydev);
-
 		if (err)
 			break;
 
@@ -782,7 +767,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_FORCING:
 		err = genphy_update_link(phydev);
-
 		if (err)
 			break;
 
@@ -805,7 +789,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_CHANGELINK:
 		err = phy_read_status(phydev);
-
 		if (err)
 			break;
 
@@ -832,14 +815,11 @@ void phy_state_machine(struct work_struc
 		}
 		break;
 	case PHY_RESUMING:
-
 		err = phy_clear_interrupt(phydev);
-
 		if (err)
 			break;
 
 		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
-
 		if (err)
 			break;
 
@@ -1108,9 +1088,8 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
  */
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
-	int val;
+	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
 
-	val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
 	phy_write_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
 			       phydev->addr, val);
 
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -72,9 +72,8 @@ static int phy_attach_direct(struct net_
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
 		       int (*run)(struct phy_device *))
 {
-	struct phy_fixup *fixup;
+	struct phy_fixup *fixup = kzalloc(sizeof(*fixup), GFP_KERNEL);
 
-	fixup = kzalloc(sizeof(*fixup), GFP_KERNEL);
 	if (!fixup)
 		return -ENOMEM;
 
@@ -132,9 +131,7 @@ int phy_scan_fixups(struct phy_device *p
 	mutex_lock(&phy_fixup_lock);
 	list_for_each_entry(fixup, &phy_fixup_list, list) {
 		if (phy_needs_fixup(phydev, fixup)) {
-			int err;
-
-			err = fixup->run(phydev);
+			int err = fixup->run(phydev);
 
 			if (err < 0) {
 				mutex_unlock(&phy_fixup_lock);
@@ -156,7 +153,6 @@ struct phy_device *phy_device_create(str
 
 	/* We allocate the device, and initialize the default values */
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
-
 	if (NULL == dev)
 		return (struct phy_device *)PTR_ERR((void *)-ENOMEM);
 
@@ -299,7 +295,6 @@ static int get_phy_id(struct mii_bus *bu
 
 	/* Grab the bits from PHYIR1, and put them in the upper half */
 	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
-
 	if (phy_reg < 0)
 		return -EIO;
 
@@ -307,7 +302,6 @@ static int get_phy_id(struct mii_bus *bu
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
 	phy_reg = mdiobus_read(bus, addr, MII_PHYSID2);
-
 	if (phy_reg < 0)
 		return -EIO;
 
@@ -729,7 +723,6 @@ static int genphy_config_advert(struct p
 
 	/* Setup standard advertisement */
 	adv = phy_read(phydev, MII_ADVERTISE);
-
 	if (adv < 0)
 		return adv;
 
@@ -750,7 +743,6 @@ static int genphy_config_advert(struct p
 	if (phydev->supported & (SUPPORTED_1000baseT_Half |
 				 SUPPORTED_1000baseT_Full)) {
 		adv = phy_read(phydev, MII_CTRL1000);
-
 		if (adv < 0)
 			return adv;
 
@@ -803,9 +795,7 @@ EXPORT_SYMBOL(genphy_setup_forced);
  */
 int genphy_restart_aneg(struct phy_device *phydev)
 {
-	int ctl;
-
-	ctl = phy_read(phydev, MII_BMCR);
+	int ctl = phy_read(phydev, MII_BMCR);
 
 	if (ctl < 0)
 		return ctl;
@@ -815,13 +805,10 @@ int genphy_restart_aneg(struct phy_devic
 	/* Don't isolate the PHY if we're negotiating */
 	ctl &= ~BMCR_ISOLATE;
 
-	ctl = phy_write(phydev, MII_BMCR, ctl);
-
-	return ctl;
+	return phy_write(phydev, MII_BMCR, ctl);
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
-
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
  * @phydev: target phy_device struct
@@ -838,10 +825,8 @@ int genphy_config_aneg(struct phy_device
 		return genphy_setup_forced(phydev);
 
 	result = genphy_config_advert(phydev);
-
 	if (result < 0) /* error */
 		return result;
-
 	if (result == 0) {
 		/* Advertisement hasn't changed, but maybe aneg was never on to
 		 * begin with?  Or maybe phy was isolated?
@@ -879,13 +864,11 @@ int genphy_update_link(struct phy_device
 
 	/* Do a fake read */
 	status = phy_read(phydev, MII_BMSR);
-
 	if (status < 0)
 		return status;
 
 	/* Read link and autonegotiation status */
 	status = phy_read(phydev, MII_BMSR);
-
 	if (status < 0)
 		return status;
 
@@ -925,12 +908,10 @@ int genphy_read_status(struct phy_device
 		if (phydev->supported & (SUPPORTED_1000baseT_Half
 					| SUPPORTED_1000baseT_Full)) {
 			lpagb = phy_read(phydev, MII_STAT1000);
-
 			if (lpagb < 0)
 				return lpagb;
 
 			adv = phy_read(phydev, MII_CTRL1000);
-
 			if (adv < 0)
 				return adv;
 
@@ -940,14 +921,12 @@ int genphy_read_status(struct phy_device
 		}
 
 		lpa = phy_read(phydev, MII_LPA);
-
 		if (lpa < 0)
 			return lpa;
 
 		phydev->lp_advertising |= mii_lpa_to_ethtool_lpa_t(lpa);
 
 		adv = phy_read(phydev, MII_ADVERTISE);
-
 		if (adv < 0)
 			return adv;
 
@@ -1016,7 +995,6 @@ static int genphy_config_init(struct phy
 
 	/* Do we support autonegotiation? */
 	val = phy_read(phydev, MII_BMSR);
-
 	if (val < 0)
 		return val;
 
@@ -1034,7 +1012,6 @@ static int genphy_config_init(struct phy
 
 	if (val & BMSR_ESTATEN) {
 		val = phy_read(phydev, MII_ESTATUS);
-
 		if (val < 0)
 			return val;
 
@@ -1089,15 +1066,11 @@ EXPORT_SYMBOL(genphy_resume);
  */
 static int phy_probe(struct device *dev)
 {
-	struct phy_device *phydev;
-	struct phy_driver *phydrv;
-	struct device_driver *drv;
+	struct phy_device *phydev = to_phy_device(dev);
+	struct device_driver *drv = phydev->dev.driver;
+	struct phy_driver *phydrv = to_phy_driver(drv);
 	int err = 0;
 
-	phydev = to_phy_device(dev);
-
-	drv = phydev->dev.driver;
-	phydrv = to_phy_driver(drv);
 	phydev->drv = phydrv;
 
 	/* Disable the interrupt if the PHY doesn't support it
@@ -1132,9 +1105,7 @@ static int phy_probe(struct device *dev)
 
 static int phy_remove(struct device *dev)
 {
-	struct phy_device *phydev;
-
-	phydev = to_phy_device(dev);
+	struct phy_device *phydev = to_phy_device(dev);
 
 	mutex_lock(&phydev->lock);
 	phydev->state = PHY_DOWN;
@@ -1161,7 +1132,6 @@ int phy_driver_register(struct phy_drive
 	new_driver->driver.remove = phy_remove;
 
 	retval = driver_register(&new_driver->driver);
-
 	if (retval) {
 		pr_err("%s: Error %d in registering driver\n",
 		       new_driver->name, retval);
