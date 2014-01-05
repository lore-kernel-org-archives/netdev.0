From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 6/8] phy: kill excess empty lines
Date: Sun, 5 Jan 2014 03:24:55 +0300
Message-ID: <201401050324.56097.sergei.shtylyov@cogentembedded.com>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:52904 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152AbaADXY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:24:57 -0500
Received: by mail-lb0-f172.google.com with SMTP id x18so9049006lbi.3
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:24:55 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id t9sm50795513lat.1.2014.01.04.15.24.54
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:24:55 -0800 (PST)
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove excess empty lines such as those between a function call and its result
check and just duplicate ones between functions.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- split from the previous patch in series;
- killed 2 lines in phy_disable_interrupts().

 drivers/net/phy/phy.c        |   14 --------------
 drivers/net/phy/phy_device.c |   17 -----------------
 2 files changed, 31 deletions(-)

Index: net-next/drivers/net/phy/phy.c
===================================================================
--- net-next.orig/drivers/net/phy/phy.c
+++ net-next/drivers/net/phy/phy.c
@@ -384,7 +384,6 @@ int phy_start_aneg(struct phy_device *ph
 		phy_sanitize_settings(phydev);
 
 	err = phydev->drv->config_aneg(phydev);
-
 	if (err < 0)
 		goto out_unlock;
 
@@ -404,7 +403,6 @@ out_unlock:
 }
 EXPORT_SYMBOL(phy_start_aneg);
 
-
 /**
  * phy_start_machine - start PHY state machine tracking
  * @phydev: the phy_device struct
@@ -514,13 +512,11 @@ static int phy_disable_interrupts(struct
 
 	/* Disable PHY interrupts */
 	err = phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
-
 	if (err)
 		goto phy_err;
 
 	/* Clear the interrupt */
 	err = phy_clear_interrupt(phydev);
-
 	if (err)
 		goto phy_err;
 
@@ -589,7 +585,6 @@ int phy_stop_interrupts(struct phy_devic
 }
 EXPORT_SYMBOL(phy_stop_interrupts);
 
-
 /**
  * phy_change - Scheduled by the phy_interrupt/timer to handle PHY changes
  * @work: work_struct that describes the work to be done
@@ -622,7 +617,6 @@ void phy_change(struct work_struct *work
 	/* reschedule state queue work to run as soon as possible */
 	cancel_delayed_work_sync(&phydev->state_queue);
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
-
 	return;
 
 ignore:
@@ -668,7 +662,6 @@ out_unlock:
 }
 EXPORT_SYMBOL(phy_stop);
 
-
 /**
  * phy_start - start or restart a PHY device
  * @phydev: target phy_device struct
@@ -730,7 +723,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_AN:
 		err = phy_read_status(phydev);
-
 		if (err < 0)
 			break;
 
@@ -762,7 +754,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_NOLINK:
 		err = phy_read_status(phydev);
-
 		if (err)
 			break;
 
@@ -774,7 +765,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_FORCING:
 		err = genphy_update_link(phydev);
-
 		if (err)
 			break;
 
@@ -797,7 +787,6 @@ void phy_state_machine(struct work_struc
 		break;
 	case PHY_CHANGELINK:
 		err = phy_read_status(phydev);
-
 		if (err)
 			break;
 
@@ -824,14 +813,11 @@ void phy_state_machine(struct work_struc
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
 
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -151,7 +151,6 @@ struct phy_device *phy_device_create(str
 
 	/* We allocate the device, and initialize the default values */
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
-
 	if (NULL == dev)
 		return (struct phy_device *)PTR_ERR((void *)-ENOMEM);
 
@@ -294,7 +293,6 @@ static int get_phy_id(struct mii_bus *bu
 
 	/* Grab the bits from PHYIR1, and put them in the upper half */
 	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
-
 	if (phy_reg < 0)
 		return -EIO;
 
@@ -302,7 +300,6 @@ static int get_phy_id(struct mii_bus *bu
 
 	/* Grab the bits from PHYIR2, and put them in the lower half */
 	phy_reg = mdiobus_read(bus, addr, MII_PHYSID2);
-
 	if (phy_reg < 0)
 		return -EIO;
 
@@ -724,7 +721,6 @@ static int genphy_config_advert(struct p
 
 	/* Setup standard advertisement */
 	adv = phy_read(phydev, MII_ADVERTISE);
-
 	if (adv < 0)
 		return adv;
 
@@ -745,7 +741,6 @@ static int genphy_config_advert(struct p
 	if (phydev->supported & (SUPPORTED_1000baseT_Half |
 				 SUPPORTED_1000baseT_Full)) {
 		adv = phy_read(phydev, MII_CTRL1000);
-
 		if (adv < 0)
 			return adv;
 
@@ -812,7 +807,6 @@ int genphy_restart_aneg(struct phy_devic
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
-
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
  * @phydev: target phy_device struct
@@ -829,10 +823,8 @@ int genphy_config_aneg(struct phy_device
 		return genphy_setup_forced(phydev);
 
 	result = genphy_config_advert(phydev);
-
 	if (result < 0) /* error */
 		return result;
-
 	if (result == 0) {
 		/* Advertisement hasn't changed, but maybe aneg was never on to
 		 * begin with?  Or maybe phy was isolated?
@@ -870,13 +862,11 @@ int genphy_update_link(struct phy_device
 
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
 
@@ -916,12 +906,10 @@ int genphy_read_status(struct phy_device
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
 
@@ -931,14 +919,12 @@ int genphy_read_status(struct phy_device
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
 
@@ -1007,7 +993,6 @@ static int genphy_config_init(struct phy
 
 	/* Do we support autonegotiation? */
 	val = phy_read(phydev, MII_BMSR);
-
 	if (val < 0)
 		return val;
 
@@ -1025,7 +1010,6 @@ static int genphy_config_init(struct phy
 
 	if (val & BMSR_ESTATEN) {
 		val = phy_read(phydev, MII_ESTATUS);
-
 		if (val < 0)
 			return val;
 
@@ -1146,7 +1130,6 @@ int phy_driver_register(struct phy_drive
 	new_driver->driver.remove = phy_remove;
 
 	retval = driver_register(&new_driver->driver);
-
 	if (retval) {
 		pr_err("%s: Error %d in registering driver\n",
 		       new_driver->name, retval);
