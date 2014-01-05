From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 5/8] phy: kill excess code
Date: Sun, 5 Jan 2014 03:23:19 +0300
Message-ID: <201401050323.20133.sergei.shtylyov@cogentembedded.com>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35051 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbaADXXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 18:23:21 -0500
Received: by mail-lb0-f178.google.com with SMTP id c11so8822013lbj.23
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 15:23:19 -0800 (PST)
Received: from wasted.dev.rtsoft.ru (ppp91-76-87-5.pppoe.mtu-net.ru. [91.76.87.5])
        by mx.google.com with ESMTPSA id di11sm50800385lac.0.2014.01.04.15.23.18
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Jan 2014 15:23:19 -0800 (PST)
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some excess code:

- convert assignments to initializers;

- kill useless assignments before *return*.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- split removal of empty lines into a new patch.

 drivers/net/phy/phy.c        |   19 +++++--------------
 drivers/net/phy/phy_device.c |   29 ++++++++---------------------
 2 files changed, 13 insertions(+), 35 deletions(-)

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
@@ -498,16 +496,12 @@ static irqreturn_t phy_interrupt(int irq
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
@@ -571,9 +565,7 @@ EXPORT_SYMBOL(phy_start_interrupts);
  */
 int phy_stop_interrupts(struct phy_device *phydev)
 {
-	int err;
-
-	err = phy_disable_interrupts(phydev);
+	int err = phy_disable_interrupts(phydev);
 
 	if (err)
 		phy_error(phydev);
@@ -1108,9 +1100,8 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
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
@@ -70,9 +70,8 @@ static int phy_attach_direct(struct net_
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
 		       int (*run)(struct phy_device *))
 {
-	struct phy_fixup *fixup;
+	struct phy_fixup *fixup = kzalloc(sizeof(*fixup), GFP_KERNEL);
 
-	fixup = kzalloc(sizeof(*fixup), GFP_KERNEL);
 	if (!fixup)
 		return -ENOMEM;
 
@@ -130,9 +129,7 @@ int phy_scan_fixups(struct phy_device *p
 	mutex_lock(&phy_fixup_lock);
 	list_for_each_entry(fixup, &phy_fixup_list, list) {
 		if (phy_needs_fixup(phydev, fixup)) {
-			int err;
-
-			err = fixup->run(phydev);
+			int err = fixup->run(phydev);
 
 			if (err < 0) {
 				mutex_unlock(&phy_fixup_lock);
@@ -801,9 +798,7 @@ EXPORT_SYMBOL(genphy_setup_forced);
  */
 int genphy_restart_aneg(struct phy_device *phydev)
 {
-	int ctl;
-
-	ctl = phy_read(phydev, MII_BMCR);
+	int ctl = phy_read(phydev, MII_BMCR);
 
 	if (ctl < 0)
 		return ctl;
@@ -813,9 +808,7 @@ int genphy_restart_aneg(struct phy_devic
 	/* Don't isolate the PHY if we're negotiating */
 	ctl &= ~BMCR_ISOLATE;
 
-	ctl = phy_write(phydev, MII_BMCR, ctl);
-
-	return ctl;
+	return phy_write(phydev, MII_BMCR, ctl);
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
@@ -1087,15 +1080,11 @@ EXPORT_SYMBOL(genphy_resume);
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
@@ -1130,9 +1119,7 @@ static int phy_probe(struct device *dev)
 
 static int phy_remove(struct device *dev)
 {
-	struct phy_device *phydev;
-
-	phydev = to_phy_device(dev);
+	struct phy_device *phydev = to_phy_device(dev);
 
 	mutex_lock(&phydev->lock);
 	phydev->state = PHY_DOWN;
