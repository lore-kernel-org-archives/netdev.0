From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 1/8] phy: coding style fixes
Date: Sun, 5 Jan 2014 03:17:06 +0300
Message-ID: <201401050317.06867.sergei.shtylyov@cogentembedded.com>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:46817 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbaADXRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:17:08 -0500
Received: by mail-la0-f46.google.com with SMTP id eh20so8872481lab.5
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:17:06 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id bo10sm39481252lbb.16.2014.01.04.15.17.05
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:17:06 -0800 (PST)
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent patch from Florian Fainelli fixed all 'checkpatch.pl' errors but left
the numerous warnings:

- including <asm/io.h> instead of <linux/io.h>;

- including <asm/uaccess.h> instead of <linux/uaccess.h>;

- *extern* declaration in .c file;

- block comments using empty /* line;

- block comments not starting with * on the middle lines; 

- block comments not having trailing */ on a separate line;

- EXPORT_SYMBOL() not immediately following its function;

- unnecessary {} for signle statement block;

- spaces before tabs.

While fixing these, also fix the following style issues (some of which were
found running 'checkpatch.pl --strict'):

- alignment not matching open paren;

- missing {} on one of the *if* arms where another has them;

- use of sizeof(struct structure) instead of sizeof(*variable);

- multiple assignments on one line;

- empty line before };

- file names in the heading comments;

- missing spaces around operators;

- no {} around multi-line *if* operator's arm;

- unneeded () around subexpressions;

- incomplete kernel-doc comment style;

- comment line exceeding 80 characters;

- missing empty line after declarations.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- removed mdio_bus_{init|exit}() declarations already present in <linux/phy.h>.

 drivers/net/phy/phy.c        |   82 ++++++++++-------------
 drivers/net/phy/phy_device.c |  149 ++++++++++++++++++++++---------------------
 2 files changed, 114 insertions(+), 117 deletions(-)

Index: net-next/drivers/net/phy/phy.c
===================================================================
--- net-next.orig/drivers/net/phy/phy.c
+++ net-next/drivers/net/phy/phy.c
@@ -1,7 +1,4 @@
-/*
- * drivers/net/phy/phy.c
- *
- * Framework for configuring and reading PHY devices
+/* Framework for configuring and reading PHY devices
  * Based on code in sungem_phy.c and gianfar_phy.c
  *
  * Author: Andy Fleming
@@ -36,11 +33,11 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mdio.h>
-
+#include <linux/io.h>
+#include <linux/uaccess.h>
 #include <linux/atomic.h>
-#include <asm/io.h>
+
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 /**
  * phy_print_status - Convenience function to print out the current phy status
@@ -48,13 +45,14 @@
  */
 void phy_print_status(struct phy_device *phydev)
 {
-	if (phydev->link)
+	if (phydev->link) {
 		pr_info("%s - Link is Up - %d/%s\n",
 			dev_name(&phydev->dev),
 			phydev->speed,
 			DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
-	else
+	} else	{
 		pr_info("%s - Link is Down\n", dev_name(&phydev->dev));
+	}
 }
 EXPORT_SYMBOL(phy_print_status);
 
@@ -114,7 +112,8 @@ static inline int phy_aneg_done(struct p
 }
 
 /* A structure for mapping a particular speed and duplex
- * combination to a particular SUPPORTED and ADVERTISED value */
+ * combination to a particular SUPPORTED and ADVERTISED value
+ */
 struct phy_setting {
 	int speed;
 	int duplex;
@@ -177,8 +176,7 @@ static inline int phy_find_setting(int s
 	int idx = 0;
 
 	while (idx < ARRAY_SIZE(settings) &&
-			(settings[idx].speed != speed ||
-			settings[idx].duplex != duplex))
+	       (settings[idx].speed != speed || settings[idx].duplex != duplex))
 		idx++;
 
 	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
@@ -245,8 +243,7 @@ int phy_ethtool_sset(struct phy_device *
 	if (cmd->phy_address != phydev->addr)
 		return -EINVAL;
 
-	/* We make sure that we don't pass unsupported
-	 * values in to the PHY */
+	/* We make sure that we don't pass unsupported values in to the PHY */
 	cmd->advertising &= phydev->supported;
 
 	/* Verify the settings we care about. */
@@ -313,8 +310,7 @@ EXPORT_SYMBOL(phy_ethtool_gset);
  * PHYCONTROL layer.  It changes registers without regard to
  * current state.  Use at own risk.
  */
-int phy_mii_ioctl(struct phy_device *phydev,
-		struct ifreq *ifr, int cmd)
+int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *mii_data = if_mii(ifr);
 	u16 val = mii_data->val_in;
@@ -334,19 +330,18 @@ int phy_mii_ioctl(struct phy_device *phy
 		if (mii_data->phy_id == phydev->addr) {
 			switch (mii_data->reg_num) {
 			case MII_BMCR:
-				if ((val & (BMCR_RESET|BMCR_ANENABLE)) == 0)
+				if ((val & (BMCR_RESET | BMCR_ANENABLE)) == 0)
 					phydev->autoneg = AUTONEG_DISABLE;
 				else
 					phydev->autoneg = AUTONEG_ENABLE;
-				if ((!phydev->autoneg) && (val & BMCR_FULLDPLX))
+				if (!phydev->autoneg && (val & BMCR_FULLDPLX))
 					phydev->duplex = DUPLEX_FULL;
 				else
 					phydev->duplex = DUPLEX_HALF;
-				if ((!phydev->autoneg) &&
-						(val & BMCR_SPEED1000))
+				if (!phydev->autoneg && (val & BMCR_SPEED1000))
 					phydev->speed = SPEED_1000;
-				else if ((!phydev->autoneg) &&
-						(val & BMCR_SPEED100))
+				else if (!phydev->autoneg &&
+					 (val & BMCR_SPEED100))
 					phydev->speed = SPEED_100;
 				break;
 			case MII_ADVERTISE:
@@ -433,7 +428,7 @@ EXPORT_SYMBOL(phy_start_aneg);
  *   function.
  */
 void phy_start_machine(struct phy_device *phydev,
-		void (*handler)(struct net_device *))
+		       void (*handler)(struct net_device *))
 {
 	phydev->adjust_state = handler;
 
@@ -494,7 +489,8 @@ static irqreturn_t phy_interrupt(int irq
 	/* The MDIO bus is not allowed to be written in interrupt
 	 * context, so we need to disable the irq here.  A work
 	 * queue will write the PHY to disable and clear the
-	 * interrupt, and then reenable the irq line. */
+	 * interrupt, and then reenable the irq line.
+	 */
 	disable_irq_nosync(irq);
 	atomic_inc(&phydev->irq_disable);
 
@@ -595,15 +591,13 @@ int phy_stop_interrupts(struct phy_devic
 
 	free_irq(phydev->irq, phydev);
 
-	/*
-	 * Cannot call flush_scheduled_work() here as desired because
+	/* Cannot call flush_scheduled_work() here as desired because
 	 * of rtnl_lock(), but we do not really care about what would
 	 * be done, except from enable_irq(), so cancel any work
 	 * possibly pending and take care of the matter below.
 	 */
 	cancel_work_sync(&phydev->phy_queue);
-	/*
-	 * If work indeed has been cancelled, disable_irq() will have
+	/* If work indeed has been cancelled, disable_irq() will have
 	 * been left unbalanced from phy_interrupt() and enable_irq()
 	 * has to be called so that other devices on the line work.
 	 */
@@ -691,12 +685,12 @@ void phy_stop(struct phy_device *phydev)
 out_unlock:
 	mutex_unlock(&phydev->lock);
 
-	/*
-	 * Cannot call flush_scheduled_work() here as desired because
+	/* Cannot call flush_scheduled_work() here as desired because
 	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
 	 * will not reenable interrupts.
 	 */
 }
+EXPORT_SYMBOL(phy_stop);
 
 
 /**
@@ -727,7 +721,6 @@ void phy_start(struct phy_device *phydev
 	}
 	mutex_unlock(&phydev->lock);
 }
-EXPORT_SYMBOL(phy_stop);
 EXPORT_SYMBOL(phy_start);
 
 /**
@@ -765,8 +758,7 @@ void phy_state_machine(struct work_struc
 		if (err < 0)
 			break;
 
-		/* If the link is down, give up on
-		 * negotiation for now */
+		/* If the link is down, give up on negotiation for now */
 		if (!phydev->link) {
 			phydev->state = PHY_NOLINK;
 			netif_carrier_off(phydev->attached_dev);
@@ -774,8 +766,7 @@ void phy_state_machine(struct work_struc
 			break;
 		}
 
-		/* Check if negotiation is done.  Break
-		 * if there's an error */
+		/* Check if negotiation is done.  Break if there's an error */
 		err = phy_aneg_done(phydev);
 		if (err < 0)
 			break;
@@ -788,8 +779,7 @@ void phy_state_machine(struct work_struc
 
 		} else if (0 == phydev->link_timeout--) {
 			needs_aneg = 1;
-			/* If we have the magic_aneg bit,
-			 * we try again */
+			/* If we have the magic_aneg bit, we try again */
 			if (phydev->drv->flags & PHY_HAS_MAGICANEG)
 				break;
 		}
@@ -847,7 +837,7 @@ void phy_state_machine(struct work_struc
 
 		if (phy_interrupt_is_valid(phydev))
 			err = phy_config_interrupt(phydev,
-					PHY_INTERRUPT_ENABLED);
+						   PHY_INTERRUPT_ENABLED);
 		break;
 	case PHY_HALTED:
 		if (phydev->link) {
@@ -864,8 +854,7 @@ void phy_state_machine(struct work_struc
 		if (err)
 			break;
 
-		err = phy_config_interrupt(phydev,
-				PHY_INTERRUPT_ENABLED);
+		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
 
 		if (err)
 			break;
@@ -876,8 +865,8 @@ void phy_state_machine(struct work_struc
 				break;
 
 			/* err > 0 if AN is done.
-			 * Otherwise, it's 0, and we're
-			 * still waiting for AN */
+			 * Otherwise, it's 0, and we're  still waiting for AN
+			 */
 			if (err > 0) {
 				err = phy_read_status(phydev);
 				if (err)
@@ -886,8 +875,9 @@ void phy_state_machine(struct work_struc
 				if (phydev->link) {
 					phydev->state = PHY_RUNNING;
 					netif_carrier_on(phydev->attached_dev);
-				} else
+				} else	{
 					phydev->state = PHY_NOLINK;
+				}
 				phydev->adjust_link(phydev->attached_dev);
 			} else {
 				phydev->state = PHY_AN;
@@ -901,8 +891,9 @@ void phy_state_machine(struct work_struc
 			if (phydev->link) {
 				phydev->state = PHY_RUNNING;
 				netif_carrier_on(phydev->attached_dev);
-			} else
+			} else	{
 				phydev->state = PHY_NOLINK;
+			}
 			phydev->adjust_link(phydev->attached_dev);
 		}
 		break;
@@ -920,7 +911,7 @@ void phy_state_machine(struct work_struc
 		phy_error(phydev);
 
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
-			PHY_STATE_TIME * HZ);
+			   PHY_STATE_TIME * HZ);
 }
 
 void phy_mac_interrupt(struct phy_device *phydev, int new_link)
@@ -1091,7 +1082,6 @@ int phy_get_eee_err(struct phy_device *p
 {
 	return phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_WK_ERR,
 				     MDIO_MMD_PCS, phydev->addr);
-
 }
 EXPORT_SYMBOL(phy_get_eee_err);
 
Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -1,7 +1,4 @@
-/*
- * drivers/net/phy/phy_device.c
- *
- * Framework for finding and configuring PHYs.
+/* Framework for finding and configuring PHYs.
  * Also contains generic PHY driver
  *
  * Author: Andy Fleming
@@ -33,10 +30,10 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
 
-#include <asm/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
 
 MODULE_DESCRIPTION("PHY library");
 MODULE_AUTHOR("Andy Fleming");
@@ -54,8 +51,6 @@ static void phy_device_release(struct de
 }
 
 static struct phy_driver genphy_driver;
-extern int mdio_bus_init(void);
-extern void mdio_bus_exit(void);
 
 static LIST_HEAD(phy_fixup_list);
 static DEFINE_MUTEX(phy_fixup_lock);
@@ -63,21 +58,21 @@ static DEFINE_MUTEX(phy_fixup_lock);
 static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			     u32 flags, phy_interface_t interface);
 
-/*
- * Creates a new phy_fixup and adds it to the list
+/**
+ * phy_register_fixup - creates a new phy_fixup and adds it to the list
  * @bus_id: A string which matches phydev->dev.bus_id (or PHY_ANY_ID)
  * @phy_uid: Used to match against phydev->phy_id (the UID of the PHY)
- * 	It can also be PHY_ANY_UID
+ *	It can also be PHY_ANY_UID
  * @phy_uid_mask: Applied to phydev->phy_id and fixup->phy_uid before
- * 	comparison
+ *	comparison
  * @run: The actual code to be run when a matching PHY is found
  */
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
-		int (*run)(struct phy_device *))
+		       int (*run)(struct phy_device *))
 {
 	struct phy_fixup *fixup;
 
-	fixup = kzalloc(sizeof(struct phy_fixup), GFP_KERNEL);
+	fixup = kzalloc(sizeof(*fixup), GFP_KERNEL);
 	if (!fixup)
 		return -ENOMEM;
 
@@ -96,7 +91,7 @@ EXPORT_SYMBOL(phy_register_fixup);
 
 /* Registers a fixup to be run on any PHY with the UID in phy_uid */
 int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
-		int (*run)(struct phy_device *))
+			       int (*run)(struct phy_device *))
 {
 	return phy_register_fixup(PHY_ANY_ID, phy_uid, phy_uid_mask, run);
 }
@@ -104,14 +99,13 @@ EXPORT_SYMBOL(phy_register_fixup_for_uid
 
 /* Registers a fixup to be run on the PHY with id string bus_id */
 int phy_register_fixup_for_id(const char *bus_id,
-		int (*run)(struct phy_device *))
+			      int (*run)(struct phy_device *))
 {
 	return phy_register_fixup(bus_id, PHY_ANY_UID, 0xffffffff, run);
 }
 EXPORT_SYMBOL(phy_register_fixup_for_id);
 
-/*
- * Returns 1 if fixup matches phydev in bus_id and phy_uid.
+/* Returns 1 if fixup matches phydev in bus_id and phy_uid.
  * Fixups can be set to match any in one or more fields.
  */
 static int phy_needs_fixup(struct phy_device *phydev, struct phy_fixup *fixup)
@@ -121,7 +115,7 @@ static int phy_needs_fixup(struct phy_de
 			return 0;
 
 	if ((fixup->phy_uid & fixup->phy_uid_mask) !=
-			(phydev->phy_id & fixup->phy_uid_mask))
+	    (phydev->phy_id & fixup->phy_uid_mask))
 		if (fixup->phy_uid != PHY_ANY_UID)
 			return 0;
 
@@ -153,12 +147,12 @@ int phy_scan_fixups(struct phy_device *p
 EXPORT_SYMBOL(phy_scan_fixups);
 
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
-			bool is_c45, struct phy_c45_device_ids *c45_ids)
+				     bool is_c45,
+				     struct phy_c45_device_ids *c45_ids)
 {
 	struct phy_device *dev;
 
-	/* We allocate the device, and initialize the
-	 * default values */
+	/* We allocate the device, and initialize the default values */
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 
 	if (NULL == dev)
@@ -168,7 +162,8 @@ struct phy_device *phy_device_create(str
 
 	dev->speed = 0;
 	dev->duplex = -1;
-	dev->pause = dev->asym_pause = 0;
+	dev->pause = 0;
+	dev->asym_pause = 0;
 	dev->link = 1;
 	dev->interface = PHY_INTERFACE_MODE_GMII;
 
@@ -192,14 +187,15 @@ struct phy_device *phy_device_create(str
 	INIT_WORK(&dev->phy_queue, phy_change);
 
 	/* Request the appropriate module unconditionally; don't
-	   bother trying to do so only if it isn't already loaded,
-	   because that gets complicated. A hotplug event would have
-	   done an unconditional modprobe anyway.
-	   We don't do normal hotplug because it won't work for MDIO
-	   -- because it relies on the device staying around for long
-	   enough for the driver to get loaded. With MDIO, the NIC
-	   driver will get bored and give up as soon as it finds that
-	   there's no driver _already_ loaded. */
+	 * bother trying to do so only if it isn't already loaded,
+	 * because that gets complicated. A hotplug event would have
+	 * done an unconditional modprobe anyway.
+	 * We don't do normal hotplug because it won't work for MDIO
+	 * -- because it relies on the device staying around for long
+	 * enough for the driver to get loaded. With MDIO, the NIC
+	 * driver will get bored and give up as soon as it finds that
+	 * there's no driver _already_ loaded.
+	 */
 	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT, MDIO_ID_ARGS(phy_id));
 
 	device_initialize(&dev->dev);
@@ -299,8 +295,7 @@ static int get_phy_id(struct mii_bus *bu
 	if (is_c45)
 		return get_phy_c45_ids(bus, addr, phy_id, c45_ids);
 
-	/* Grab the bits from PHYIR1, and put them
-	 * in the upper half */
+	/* Grab the bits from PHYIR1, and put them in the upper half */
 	phy_reg = mdiobus_read(bus, addr, MII_PHYSID1);
 
 	if (phy_reg < 0)
@@ -320,7 +315,8 @@ static int get_phy_id(struct mii_bus *bu
 }
 
 /**
- * get_phy_device - reads the specified PHY device and returns its @phy_device struct
+ * get_phy_device - reads the specified PHY device and returns its @phy_device
+ *		    struct
  * @bus: the target MII bus
  * @addr: PHY address on the MII bus
  * @is_c45: If true the PHY uses the 802.3 clause 45 protocol
@@ -357,8 +353,7 @@ int phy_device_register(struct phy_devic
 {
 	int err;
 
-	/* Don't register a phy if one is already registered at this
-	 * address */
+	/* Don't register a phy if one is already registered at this address */
 	if (phydev->bus->phy_map[phydev->addr])
 		return -EINVAL;
 	phydev->bus->phy_map[phydev->addr] = phydev;
@@ -413,7 +408,7 @@ EXPORT_SYMBOL(phy_find_first);
  *   this function.
  */
 static void phy_prepare_link(struct phy_device *phydev,
-		void (*handler)(struct net_device *))
+			     void (*handler)(struct net_device *))
 {
 	phydev->adjust_link = handler;
 }
@@ -460,15 +455,16 @@ EXPORT_SYMBOL(phy_connect_direct);
  *   the desired functionality.
  */
 struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
-		void (*handler)(struct net_device *),
-		phy_interface_t interface)
+			       void (*handler)(struct net_device *),
+			       phy_interface_t interface)
 {
 	struct phy_device *phydev;
 	struct device *d;
 	int rc;
 
 	/* Search the list of PHY devices on the mdio bus for the
-	 * PHY with the requested name */
+	 * PHY with the requested name
+	 */
 	d = bus_find_device_by_name(&mdio_bus_type, NULL, bus_id);
 	if (!d) {
 		pr_err("PHY %s not found\n", bus_id);
@@ -485,7 +481,8 @@ struct phy_device *phy_connect(struct ne
 EXPORT_SYMBOL(phy_connect);
 
 /**
- * phy_disconnect - disable interrupts, stop state machine, and detach a PHY device
+ * phy_disconnect - disable interrupts, stop state machine, and detach a PHY
+ *		    device
  * @phydev: target phy_device struct
  */
 void phy_disconnect(struct phy_device *phydev)
@@ -534,8 +531,7 @@ static int phy_poll_reset(struct phy_dev
 	if (ret & BMCR_RESET)
 		return -ETIMEDOUT;
 
-	/*
-	 * Some chips (smsc911x) may still need up to another 1ms after the
+	/* Some chips (smsc911x) may still need up to another 1ms after the
 	 * BMCR_RESET bit is cleared before they are usable.
 	 */
 	msleep(1);
@@ -586,7 +582,8 @@ static int phy_attach_direct(struct net_
 	int err;
 
 	/* Assume that if there is no driver, that it doesn't
-	 * exist, and we should use the genphy driver. */
+	 * exist, and we should use the genphy driver.
+	 */
 	if (NULL == d->driver) {
 		if (phydev->is_c45) {
 			pr_err("No driver for phy %x\n", phydev->phy_id);
@@ -619,7 +616,8 @@ static int phy_attach_direct(struct net_
 
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
-	 * (dev_flags and interface) */
+	 * (dev_flags and interface)
+	 */
 	err = phy_init_hw(phydev);
 	if (err)
 		phy_detach(phydev);
@@ -638,8 +636,8 @@ static int phy_attach_direct(struct net_
  * Description: Same as phy_attach_direct() except that a PHY bus_id
  *     string is passed instead of a pointer to a struct phy_device.
  */
-struct phy_device *phy_attach(struct net_device *dev,
-		const char *bus_id, phy_interface_t interface)
+struct phy_device *phy_attach(struct net_device *dev, const char *bus_id,
+			      phy_interface_t interface)
 {
 	struct bus_type *bus = &mdio_bus_type;
 	struct phy_device *phydev;
@@ -647,7 +645,8 @@ struct phy_device *phy_attach(struct net
 	int rc;
 
 	/* Search the list of PHY devices on the mdio bus for the
-	 * PHY with the requested name */
+	 * PHY with the requested name
+	 */
 	d = bus_find_device_by_name(bus, NULL, bus_id);
 	if (!d) {
 		pr_err("PHY %s not found\n", bus_id);
@@ -676,7 +675,8 @@ void phy_detach(struct phy_device *phyde
 	/* If the device had no specific driver before (i.e. - it
 	 * was using the generic driver), we unbind the device
 	 * from the generic driver so that there's a chance a
-	 * real driver could be loaded */
+	 * real driver could be loaded
+	 */
 	if (phydev->dev.driver == &genphy_driver.driver)
 		device_release_driver(&phydev->dev);
 }
@@ -724,17 +724,17 @@ static int genphy_config_advert(struct p
 	int oldadv, adv;
 	int err, changed = 0;
 
-	/* Only allow advertising what
-	 * this PHY supports */
+	/* Only allow advertising what this PHY supports */
 	phydev->advertising &= phydev->supported;
 	advertise = phydev->advertising;
 
 	/* Setup standard advertisement */
-	oldadv = adv = phy_read(phydev, MII_ADVERTISE);
+	adv = phy_read(phydev, MII_ADVERTISE);
 
 	if (adv < 0)
 		return adv;
 
+	oldadv = adv;
 	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP |
 		 ADVERTISE_PAUSE_ASYM);
 	adv |= ethtool_adv_to_mii_adv_t(advertise);
@@ -749,12 +749,13 @@ static int genphy_config_advert(struct p
 
 	/* Configure gigabit if it's supported */
 	if (phydev->supported & (SUPPORTED_1000baseT_Half |
-				SUPPORTED_1000baseT_Full)) {
-		oldadv = adv = phy_read(phydev, MII_CTRL1000);
+				 SUPPORTED_1000baseT_Full)) {
+		adv = phy_read(phydev, MII_CTRL1000);
 
 		if (adv < 0)
 			return adv;
 
+		oldadv = adv;
 		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 		adv |= ethtool_adv_to_mii_ctrl1000_t(advertise);
 
@@ -783,7 +784,8 @@ int genphy_setup_forced(struct phy_devic
 	int err;
 	int ctl = 0;
 
-	phydev->pause = phydev->asym_pause = 0;
+	phydev->pause = 0;
+	phydev->asym_pause = 0;
 
 	if (SPEED_1000 == phydev->speed)
 		ctl |= BMCR_SPEED1000;
@@ -812,10 +814,10 @@ int genphy_restart_aneg(struct phy_devic
 	if (ctl < 0)
 		return ctl;
 
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	ctl |= BMCR_ANENABLE | BMCR_ANRESTART;
 
 	/* Don't isolate the PHY if we're negotiating */
-	ctl &= ~(BMCR_ISOLATE);
+	ctl &= ~BMCR_ISOLATE;
 
 	ctl = phy_write(phydev, MII_BMCR, ctl);
 
@@ -846,7 +848,8 @@ int genphy_config_aneg(struct phy_device
 
 	if (result == 0) {
 		/* Advertisement hasn't changed, but maybe aneg was never on to
-		 * begin with?  Or maybe phy was isolated? */
+		 * begin with?  Or maybe phy was isolated?
+		 */
 		int ctl = phy_read(phydev, MII_BMCR);
 
 		if (ctl < 0)
@@ -857,7 +860,8 @@ int genphy_config_aneg(struct phy_device
 	}
 
 	/* Only restart aneg if we are advertising something different
-	 * than we were before.	 */
+	 * than we were before.
+	 */
 	if (result > 0)
 		result = genphy_restart_aneg(phydev);
 
@@ -914,8 +918,7 @@ int genphy_read_status(struct phy_device
 	int lpa;
 	int lpagb = 0;
 
-	/* Update the link, but return if there
-	 * was an error */
+	/* Update the link, but return if there was an error */
 	err = genphy_update_link(phydev);
 	if (err)
 		return err;
@@ -956,7 +959,8 @@ int genphy_read_status(struct phy_device
 
 		phydev->speed = SPEED_10;
 		phydev->duplex = DUPLEX_HALF;
-		phydev->pause = phydev->asym_pause = 0;
+		phydev->pause = 0;
+		phydev->asym_pause = 0;
 
 		if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
 			phydev->speed = SPEED_1000;
@@ -978,6 +982,7 @@ int genphy_read_status(struct phy_device
 		}
 	} else {
 		int bmcr = phy_read(phydev, MII_BMCR);
+
 		if (bmcr < 0)
 			return bmcr;
 
@@ -993,7 +998,8 @@ int genphy_read_status(struct phy_device
 		else
 			phydev->speed = SPEED_10;
 
-		phydev->pause = phydev->asym_pause = 0;
+		phydev->pause = 0;
+		phydev->asym_pause = 0;
 	}
 
 	return 0;
@@ -1006,7 +1012,8 @@ static int genphy_config_init(struct phy
 	u32 features;
 
 	/* For now, I'll claim that the generic driver supports
-	 * all possible port types */
+	 * all possible port types
+	 */
 	features = (SUPPORTED_TP | SUPPORTED_MII
 			| SUPPORTED_AUI | SUPPORTED_FIBRE |
 			SUPPORTED_BNC);
@@ -1053,7 +1060,7 @@ int genphy_suspend(struct phy_device *ph
 	mutex_lock(&phydev->lock);
 
 	value = phy_read(phydev, MII_BMCR);
-	phy_write(phydev, MII_BMCR, (value | BMCR_PDOWN));
+	phy_write(phydev, MII_BMCR, value | BMCR_PDOWN);
 
 	mutex_unlock(&phydev->lock);
 
@@ -1068,7 +1075,7 @@ int genphy_resume(struct phy_device *phy
 	mutex_lock(&phydev->lock);
 
 	value = phy_read(phydev, MII_BMCR);
-	phy_write(phydev, MII_BMCR, (value & ~BMCR_PDOWN));
+	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
 
 	mutex_unlock(&phydev->lock);
 
@@ -1101,7 +1108,7 @@ static int phy_probe(struct device *dev)
 	 * but the interrupt is still a valid one
 	 */
 	if (!(phydrv->flags & PHY_HAS_INTERRUPT) &&
-			phy_interrupt_is_valid(phydev))
+	    phy_interrupt_is_valid(phydev))
 		phydev->irq = PHY_POLL;
 
 	if (phydrv->flags & PHY_IS_INTERNAL)
@@ -1111,7 +1118,8 @@ static int phy_probe(struct device *dev)
 
 	/* Start out supporting everything. Eventually,
 	 * a controller will attach, and may modify one
-	 * or both of these values */
+	 * or both of these values
+	 */
 	phydev->supported = phydrv->features;
 	phydev->advertising = phydrv->features;
 
@@ -1124,7 +1132,6 @@ static int phy_probe(struct device *dev)
 	mutex_unlock(&phydev->lock);
 
 	return err;
-
 }
 
 static int phy_remove(struct device *dev)
@@ -1197,9 +1204,9 @@ EXPORT_SYMBOL(phy_driver_unregister);
 void phy_drivers_unregister(struct phy_driver *drv, int n)
 {
 	int i;
-	for (i = 0; i < n; i++) {
+
+	for (i = 0; i < n; i++)
 		phy_driver_unregister(drv + i);
-	}
 }
 EXPORT_SYMBOL(phy_drivers_unregister);
 
