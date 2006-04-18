From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] sync bcm43xx-d80211 to bcm43xx
Date: Tue, 18 Apr 2006 16:48:04 +0200
Message-ID: <200604181648.04987.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1645309.IhusCoZDVJ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:28112
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751028AbWDRPAo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 11:00:44 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1645309.IhusCoZDVJ
Content-Type: multipart/mixed;
  boundary="Boundary-01=_kwPREq65AcXgLeP"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_kwPREq65AcXgLeP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi John,

I already sent these three patches for inclusion into
the softmac version of the driver. Here are the devicescape
port versions for inclusion in your wireless-dev tree.

=2D-=20
Greetings Michael.

--Boundary-01=_kwPREq65AcXgLeP
Content-Type: text/x-diff;
  charset="us-ascii";
  name="bcm43xx-d80211_clean_up_sysfs_stuff.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="bcm43xx-d80211_clean_up_sysfs_stuff.patch"

Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev-ds.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h	20=
06-04-18 16:33:23.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx.h	2006-04-1=
8 16:38:10.000000000 +0200
@@ -18,7 +18,6 @@
=20
 #include "bcm43xx_debugfs.h"
 #include "bcm43xx_leds.h"
=2D#include "bcm43xx_sysfs.h"
=20
=20
 #define PFX				KBUILD_MODNAME ": "
@@ -628,8 +627,6 @@
 };
=20
 struct bcm43xx_private {
=2D	struct bcm43xx_sysfs sysfs;
=2D
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
 	int iw_mode;
@@ -843,6 +840,20 @@
 	return phy->_lo_pairs + (radio_attenuation + 14 * (baseband_attenuation /=
 2));
 }
=20
+struct device;
+
+static inline
+struct bcm43xx_private * dev_to_bcm(struct device *dev)
+{
+	struct net_device *net_dev;
+	struct bcm43xx_private *bcm;
+
+	net_dev =3D dev_get_drvdata(dev);
+	bcm =3D bcm43xx_priv(net_dev);
+
+	return bcm;
+}
+
=20
 static inline
 u16 bcm43xx_read16(struct bcm43xx_private *bcm, u16 offset)
Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev-ds.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main=
=2Ec	2006-04-18 16:33:23.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c	2006=
=2D04-18 16:37:48.000000000 +0200
@@ -52,6 +52,7 @@
 #include "bcm43xx_sysfs.h"
 #include "bcm43xx_ethtool.h"
 #include "bcm43xx_xmit.h"
+#include "bcm43xx_sysfs.h"
=20
=20
 MODULE_DESCRIPTION("Broadcom BCM43xx wireless driver");
Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysfs.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev-ds.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysf=
s.c	2006-04-18 16:33:23.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysfs.c	200=
6-04-18 16:37:48.000000000 +0200
@@ -71,14 +71,46 @@
 	return -EINVAL;
 }
=20
+static int sprom2hex(const u16 *sprom, char *buf, size_t buf_len)
+{
+	int i, pos =3D 0;
+
+	for (i =3D 0; i < BCM43xx_SPROM_SIZE; i++) {
+		pos +=3D snprintf(buf + pos, buf_len - pos - 1,
+				"%04X", swab16(sprom[i]) & 0xFFFF);
+	}
+	pos +=3D snprintf(buf + pos, buf_len - pos - 1, "\n");
+
+	return pos + 1;
+}
+
+static int hex2sprom(u16 *sprom, const char *dump, size_t len)
+{
+	char tmp[5] =3D { 0 };
+	int cnt =3D 0;
+	unsigned long parsed;
+
+	if (len < BCM43xx_SPROM_SIZE * sizeof(u16) * 2)
+		return -EINVAL;
+
+	while (cnt < BCM43xx_SPROM_SIZE) {
+		memcpy(tmp, dump, 4);
+		dump +=3D 4;
+		parsed =3D simple_strtoul(tmp, NULL, 16);
+		sprom[cnt++] =3D swab16((u16)parsed);
+	}
+
+	return 0;
+}
+
 static ssize_t bcm43xx_attr_sprom_show(struct device *dev,
 				       struct device_attribute *attr,
 				       char *buf)
 {
=2D	struct bcm43xx_private *bcm =3D devattr_to_bcm(attr, attr_sprom);
+	struct bcm43xx_private *bcm =3D dev_to_bcm(dev);
 	u16 *sprom;
 	unsigned long flags;
=2D	int i, err;
+	int err;
=20
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -91,55 +123,53 @@
 	bcm43xx_lock_mmio(bcm, flags);
 	assert(bcm->initialized);
 	err =3D bcm43xx_sprom_read(bcm, sprom);
=2D	if (!err) {
=2D		for (i =3D 0; i < BCM43xx_SPROM_SIZE; i++) {
=2D			buf[i * 2] =3D sprom[i] & 0x00FF;
=2D			buf[i * 2 + 1] =3D (sprom[i] & 0xFF00) >> 8;
=2D		}
=2D	}
+	if (!err)
+		err =3D sprom2hex(sprom, buf, PAGE_SIZE);
 	bcm43xx_unlock_mmio(bcm, flags);
 	kfree(sprom);
=20
=2D	return err ? err : BCM43xx_SPROM_SIZE * sizeof(u16);
+	return err;
 }
=20
 static ssize_t bcm43xx_attr_sprom_store(struct device *dev,
 					struct device_attribute *attr,
 					const char *buf, size_t count)
 {
=2D	struct bcm43xx_private *bcm =3D devattr_to_bcm(attr, attr_sprom);
+	struct bcm43xx_private *bcm =3D dev_to_bcm(dev);
 	u16 *sprom;
 	unsigned long flags;
=2D	int i, err;
+	int err;
=20
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
=20
=2D	if (count !=3D BCM43xx_SPROM_SIZE * sizeof(u16))
=2D		return -EINVAL;
 	sprom =3D kmalloc(BCM43xx_SPROM_SIZE * sizeof(*sprom),
 			GFP_KERNEL);
 	if (!sprom)
 		return -ENOMEM;
=2D	for (i =3D 0; i < BCM43xx_SPROM_SIZE; i++) {
=2D		sprom[i] =3D buf[i * 2] & 0xFF;
=2D		sprom[i] |=3D ((u16)(buf[i * 2 + 1] & 0xFF)) << 8;
=2D	}
+	err =3D hex2sprom(sprom, buf, count);
+	if (err)
+		goto out_kfree;
 	bcm43xx_lock_mmio(bcm, flags);
 	assert(bcm->initialized);
 	err =3D bcm43xx_sprom_write(bcm, sprom);
 	bcm43xx_unlock_mmio(bcm, flags);
+out_kfree:
 	kfree(sprom);
=20
 	return err ? err : count;
=20
 }
=20
+static DEVICE_ATTR(sprom, 0600,
+		   bcm43xx_attr_sprom_show,
+		   bcm43xx_attr_sprom_store);
+
 static ssize_t bcm43xx_attr_interfmode_show(struct device *dev,
 					    struct device_attribute *attr,
 					    char *buf)
 {
=2D	struct bcm43xx_private *bcm =3D devattr_to_bcm(attr, attr_interfmode);
+	struct bcm43xx_private *bcm =3D dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	ssize_t count =3D 0;
@@ -175,7 +205,7 @@
 					     struct device_attribute *attr,
 					     const char *buf, size_t count)
 {
=2D	struct bcm43xx_private *bcm =3D devattr_to_bcm(attr, attr_interfmode);
+	struct bcm43xx_private *bcm =3D dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	int mode;
@@ -215,11 +245,15 @@
 	return err ? err : count;
 }
=20
+static DEVICE_ATTR(interference, 0644,
+		   bcm43xx_attr_interfmode_show,
+		   bcm43xx_attr_interfmode_store);
+
 static ssize_t bcm43xx_attr_preamble_show(struct device *dev,
 					  struct device_attribute *attr,
 					  char *buf)
 {
=2D	struct bcm43xx_private *bcm =3D devattr_to_bcm(attr, attr_preamble);
+	struct bcm43xx_private *bcm =3D dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	ssize_t count;
@@ -245,7 +279,7 @@
 					   struct device_attribute *attr,
 					   const char *buf, size_t count)
 {
=2D	struct bcm43xx_private *bcm =3D devattr_to_bcm(attr, attr_preamble);
+	struct bcm43xx_private *bcm =3D dev_to_bcm(dev);
 	unsigned long flags;
 	int err;
 	int value;
@@ -267,56 +301,41 @@
 	return err ? err : count;
 }
=20
+static DEVICE_ATTR(shortpreamble, 0644,
+		   bcm43xx_attr_preamble_show,
+		   bcm43xx_attr_preamble_store);
+
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
 {
 	struct device *dev =3D &bcm->pci_dev->dev;
=2D	struct bcm43xx_sysfs *sysfs =3D &bcm->sysfs;
 	int err;
=20
 	assert(bcm->initialized);
=20
=2D	sysfs->attr_sprom.attr.name =3D "sprom";
=2D	sysfs->attr_sprom.attr.owner =3D THIS_MODULE;
=2D	sysfs->attr_sprom.attr.mode =3D 0600;
=2D	sysfs->attr_sprom.show =3D bcm43xx_attr_sprom_show;
=2D	sysfs->attr_sprom.store =3D bcm43xx_attr_sprom_store;
=2D	err =3D device_create_file(dev, &sysfs->attr_sprom);
+	err =3D device_create_file(dev, &dev_attr_sprom);
 	if (err)
 		goto out;
=2D
=2D	sysfs->attr_interfmode.attr.name =3D "interference";
=2D	sysfs->attr_interfmode.attr.owner =3D THIS_MODULE;
=2D	sysfs->attr_interfmode.attr.mode =3D 0600;
=2D	sysfs->attr_interfmode.show =3D bcm43xx_attr_interfmode_show;
=2D	sysfs->attr_interfmode.store =3D bcm43xx_attr_interfmode_store;
=2D	err =3D device_create_file(dev, &sysfs->attr_interfmode);
+	err =3D device_create_file(dev, &dev_attr_interference);
 	if (err)
 		goto err_remove_sprom;
=2D
=2D	sysfs->attr_preamble.attr.name =3D "shortpreamble";
=2D	sysfs->attr_preamble.attr.owner =3D THIS_MODULE;
=2D	sysfs->attr_preamble.attr.mode =3D 0600;
=2D	sysfs->attr_preamble.show =3D bcm43xx_attr_preamble_show;
=2D	sysfs->attr_preamble.store =3D bcm43xx_attr_preamble_store;
=2D	err =3D device_create_file(dev, &sysfs->attr_preamble);
+	err =3D device_create_file(dev, &dev_attr_shortpreamble);
 	if (err)
 		goto err_remove_interfmode;
=20
 out:
 	return err;
 err_remove_interfmode:
=2D	device_remove_file(dev, &sysfs->attr_interfmode);
+	device_remove_file(dev, &dev_attr_interference);
 err_remove_sprom:
=2D	device_remove_file(dev, &sysfs->attr_sprom);
+	device_remove_file(dev, &dev_attr_sprom);
 	goto out;
 }
=20
 void bcm43xx_sysfs_unregister(struct bcm43xx_private *bcm)
 {
 	struct device *dev =3D &bcm->pci_dev->dev;
=2D	struct bcm43xx_sysfs *sysfs =3D &bcm->sysfs;
=20
=2D	device_remove_file(dev, &sysfs->attr_preamble);
=2D	device_remove_file(dev, &sysfs->attr_interfmode);
=2D	device_remove_file(dev, &sysfs->attr_sprom);
+	device_remove_file(dev, &dev_attr_shortpreamble);
+	device_remove_file(dev, &dev_attr_interference);
+	device_remove_file(dev, &dev_attr_sprom);
 }
Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysfs.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev-ds.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysf=
s.h	2006-04-18 16:33:23.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_sysfs.h	200=
6-04-18 16:37:48.000000000 +0200
@@ -1,22 +1,6 @@
 #ifndef BCM43xx_SYSFS_H_
 #define BCM43xx_SYSFS_H_
=20
=2D#include <linux/device.h>
=2D
=2D
=2Dstruct bcm43xx_sysfs {
=2D	struct device_attribute attr_sprom;
=2D	struct device_attribute attr_interfmode;
=2D	struct device_attribute attr_preamble;
=2D};
=2D
=2D#define devattr_to_bcm(attr, attr_name)	({				\
=2D	struct bcm43xx_sysfs *__s; struct bcm43xx_private *__p;		\
=2D	__s =3D container_of((attr), struct bcm43xx_sysfs, attr_name);	\
=2D	__p =3D container_of(__s, struct bcm43xx_private, sysfs);		\
=2D	__p;								\
=2D					})
=2D
 struct bcm43xx_private;
=20
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm);

--Boundary-01=_kwPREq65AcXgLeP
Content-Type: text/x-diff;
  charset="us-ascii";
  name="bcm43xx-d80211_pctl_clockfreqlimit_uninit_fix.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="bcm43xx-d80211_pctl_clockfreqlimit_uninit_fix.patch"

Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_power.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev-ds.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_powe=
r.c	2006-04-18 16:33:23.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_power.c	200=
6-04-18 16:38:56.000000000 +0200
@@ -35,77 +35,101 @@
 #include "bcm43xx_main.h"
=20
=20
+/* Get the Slow Clock Source */
+static int bcm43xx_pctl_get_slowclksrc(struct bcm43xx_private *bcm)
+{
+	u32 tmp;
+	int err;
+
+	assert(bcm->current_core =3D=3D &bcm->core_chipcommon);
+	if (bcm->current_core->rev < 6) {
+		if (bcm->bustype =3D=3D BCM43xx_BUSTYPE_PCMCIA ||
+		    bcm->bustype =3D=3D BCM43xx_BUSTYPE_SB)
+			return BCM43xx_PCTL_CLKSRC_XTALOS;
+		if (bcm->bustype =3D=3D BCM43xx_BUSTYPE_PCI) {
+			err =3D bcm43xx_pci_read_config32(bcm, BCM43xx_PCTL_OUT, &tmp);
+			assert(!err);
+			if (tmp & 0x10)
+				return BCM43xx_PCTL_CLKSRC_PCI;
+			return BCM43xx_PCTL_CLKSRC_XTALOS;
+		}
+	}
+	if (bcm->current_core->rev < 10) {
+		tmp =3D bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+		tmp &=3D 0x7;
+		if (tmp =3D=3D 0)
+			return BCM43xx_PCTL_CLKSRC_LOPWROS;
+		if (tmp =3D=3D 1)
+			return BCM43xx_PCTL_CLKSRC_XTALOS;
+		if (tmp =3D=3D 2)
+			return BCM43xx_PCTL_CLKSRC_PCI;
+	}
+
+	return BCM43xx_PCTL_CLKSRC_XTALOS;
+}
+
 /* Get max/min slowclock frequency
  * as described in http://bcm-specs.sipsolutions.net/PowerControl
  */
 static int bcm43xx_pctl_clockfreqlimit(struct bcm43xx_private *bcm,
 				       int get_max)
 {
=2D	int limit =3D 0;
+	int limit;
+	int clocksrc;
 	int divisor;
=2D	int selection;
=2D	int err;
 	u32 tmp;
=2D	struct bcm43xx_coreinfo *old_core;
=20
=2D	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
=2D		goto out;
=2D	old_core =3D bcm->current_core;
=2D	err =3D bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
=2D	if (err)
=2D		goto out;
+	assert(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL);
+	assert(bcm->current_core =3D=3D &bcm->core_chipcommon);
=20
+	clocksrc =3D bcm43xx_pctl_get_slowclksrc(bcm);
 	if (bcm->current_core->rev < 6) {
=2D		if ((bcm->bustype =3D=3D BCM43xx_BUSTYPE_PCMCIA) ||
=2D			(bcm->bustype =3D=3D BCM43xx_BUSTYPE_SB)) {
=2D			selection =3D 1;
+		switch (clocksrc) {
+		case BCM43xx_PCTL_CLKSRC_PCI:
+			divisor =3D 64;
+			break;
+		case BCM43xx_PCTL_CLKSRC_XTALOS:
 			divisor =3D 32;
=2D		} else {
=2D			err =3D bcm43xx_pci_read_config32(bcm, BCM43xx_PCTL_OUT, &tmp);
=2D			if (err) {
=2D				printk(KERN_ERR PFX "clockfreqlimit pcicfg read failure\n");
=2D				goto out_switchback;
=2D			}
=2D			if (tmp & 0x10) {
=2D				/* PCI */
=2D				selection =3D 2;
=2D				divisor =3D 64;
=2D			} else {
=2D				/* XTAL */
=2D				selection =3D 1;
=2D				divisor =3D 32;
=2D			}
+			break;
+		default:
+			assert(0);
+			divisor =3D 1;
 		}
 	} else if (bcm->current_core->rev < 10) {
=2D		selection =3D (tmp & 0x07);
=2D		if (selection) {
+		switch (clocksrc) {
+		case BCM43xx_PCTL_CLKSRC_LOPWROS:
+			divisor =3D 1;
+			break;
+		case BCM43xx_PCTL_CLKSRC_XTALOS:
+		case BCM43xx_PCTL_CLKSRC_PCI:
 			tmp =3D bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
=2D			divisor =3D 4 * (1 + ((tmp & 0xFFFF0000) >> 16));
=2D		} else
+			divisor =3D ((tmp & 0xFFFF0000) >> 16) + 1;
+			divisor *=3D 4;
+			break;
+		default:
+			assert(0);
 			divisor =3D 1;
+		}
 	} else {
 		tmp =3D bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL);
=2D		divisor =3D 4 * (1 + ((tmp & 0xFFFF0000) >> 16));
=2D		selection =3D 1;
+		divisor =3D ((tmp & 0xFFFF0000) >> 16) + 1;
+		divisor *=3D 4;
 	}
=2D=09
=2D	switch (selection) {
=2D	case 0:
=2D		/* LPO */
+
+	switch (clocksrc) {
+	case BCM43xx_PCTL_CLKSRC_LOPWROS:
 		if (get_max)
 			limit =3D 43000;
 		else
 			limit =3D 25000;
 		break;
=2D	case 1:
=2D		/* XTAL */
+	case BCM43xx_PCTL_CLKSRC_XTALOS:
 		if (get_max)
 			limit =3D 20200000;
 		else
 			limit =3D 19800000;
 		break;
=2D	case 2:
=2D		/* PCI */
+	case BCM43xx_PCTL_CLKSRC_PCI:
 		if (get_max)
 			limit =3D 34000000;
 		else
@@ -113,17 +137,14 @@
 		break;
 	default:
 		assert(0);
+		limit =3D 0;
 	}
 	limit /=3D divisor;
=20
=2Dout_switchback:
=2D	err =3D bcm43xx_switch_core(bcm, old_core);
=2D	assert(err =3D=3D 0);
=2D
=2Dout:
 	return limit;
 }
=20
+
 /* init power control
  * as described in http://bcm-specs.sipsolutions.net/PowerControl
  */
Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_power.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-dev-ds.orig/drivers/net/wireless/bcm43xx-d80211/bcm43xx_powe=
r.h	2006-04-18 16:33:23.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_power.h	200=
6-04-18 16:38:56.000000000 +0200
@@ -33,6 +33,15 @@
=20
 #include <linux/types.h>
=20
+/* Clock sources */
+enum {
+	/* PCI clock */
+	BCM43xx_PCTL_CLKSRC_PCI,
+	/* Crystal slow clock oscillator */
+	BCM43xx_PCTL_CLKSRC_XTALOS,
+	/* Low power oscillator */
+	BCM43xx_PCTL_CLKSRC_LOPWROS,
+};
=20
 struct bcm43xx_private;
=20

--Boundary-01=_kwPREq65AcXgLeP
Content-Type: text/x-diff;
  charset="us-ascii";
  name="bcm43xx-d80211_phy_tssi_memleak_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="bcm43xx-d80211_phy_tssi_memleak_fix.patch"

Index: wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_phy.c
===================================================================
--- wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_phy.c	2006-04-13 02:21:39.000000000 +0200
+++ wireless-dev-ds/drivers/net/wireless/bcm43xx-d80211/bcm43xx_phy.c	2006-04-13 02:23:31.000000000 +0200
@@ -2151,6 +2151,7 @@
 				phy->tssi2dbm = NULL;
 				printk(KERN_ERR PFX "Could not generate "
 						    "tssi2dBm table\n");
+				kfree(dyn_tssi2dbm);
 				return -ENODEV;
 			}
 		phy->tssi2dbm = dyn_tssi2dbm;

--Boundary-01=_kwPREq65AcXgLeP--

--nextPart1645309.IhusCoZDVJ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBERPwklb09HEdWDKgRAg49AJ42B/kdqdTxglONhgGTBHa9lTgPrgCeO5Ft
DrDA0AygVEqY19aEY/OS+PU=
=1psY
-----END PGP SIGNATURE-----

--nextPart1645309.IhusCoZDVJ--
