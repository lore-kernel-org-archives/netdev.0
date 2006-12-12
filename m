From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Consistency for address space constants
Date: Tue, 12 Dec 2006 01:25:52 +0000 (GMT)
Message-ID: <20061212012552.7ED517B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:64303 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821AbWLLB0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:26:00 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The zd1211rw address space has confused me once too many times. This
patch introduces the following naming notation:

Memory space is split into segments (cr, fw, eeprom) and segments may
contain components (e.g. boot code inside eeprom). These names are
arbitrary and only for the description below:

x_START: Absolute address of segment start
(previously these were named such as CR_BASE_OFFSET, but they weren't
really offsets unless you were considering them as an offset to 0)

x_LEN: Segment length

x_y_LEN: Length of component y of segment x

x_y_OFFSET: Relative address of component y into segment x. The absolute
address for this component is (x_START + x_y_OFFSET)

I also renamed EEPROM registers to EEPROM data. These 'registers' can't
be written to using standard I/O and really represent predefined data
from the vendor.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_chip.h  |  119 +++++++++++++++++++++++++++++++++---------------------------
 zd_types.h |    2 +-
 zd_usb.c   |   18 ++++-----
 3 files changed, 75 insertions(+), 64 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -594,49 +594,49 @@
 /*
  * Upper 16 bit contains the regulatory domain.
  */
-#define E2P_SUBID		E2P_REG(0x00)
-#define E2P_POD			E2P_REG(0x02)
-#define E2P_MAC_ADDR_P1		E2P_REG(0x04)
-#define E2P_MAC_ADDR_P2		E2P_REG(0x06)
-#define E2P_PWR_CAL_VALUE1	E2P_REG(0x08)
-#define E2P_PWR_CAL_VALUE2	E2P_REG(0x0a)
-#define E2P_PWR_CAL_VALUE3	E2P_REG(0x0c)
-#define E2P_PWR_CAL_VALUE4      E2P_REG(0x0e)
-#define E2P_PWR_INT_VALUE1	E2P_REG(0x10)
-#define E2P_PWR_INT_VALUE2	E2P_REG(0x12)
-#define E2P_PWR_INT_VALUE3	E2P_REG(0x14)
-#define E2P_PWR_INT_VALUE4	E2P_REG(0x16)
+#define E2P_SUBID		E2P_DATA(0x00)
+#define E2P_POD			E2P_DATA(0x02)
+#define E2P_MAC_ADDR_P1		E2P_DATA(0x04)
+#define E2P_MAC_ADDR_P2		E2P_DATA(0x06)
+#define E2P_PWR_CAL_VALUE1	E2P_DATA(0x08)
+#define E2P_PWR_CAL_VALUE2	E2P_DATA(0x0a)
+#define E2P_PWR_CAL_VALUE3	E2P_DATA(0x0c)
+#define E2P_PWR_CAL_VALUE4      E2P_DATA(0x0e)
+#define E2P_PWR_INT_VALUE1	E2P_DATA(0x10)
+#define E2P_PWR_INT_VALUE2	E2P_DATA(0x12)
+#define E2P_PWR_INT_VALUE3	E2P_DATA(0x14)
+#define E2P_PWR_INT_VALUE4	E2P_DATA(0x16)
 
 /* Contains a bit for each allowed channel. It gives for Europe (ETSI 0x30)
  * also only 11 channels. */
-#define E2P_ALLOWED_CHANNEL	E2P_REG(0x18)
+#define E2P_ALLOWED_CHANNEL	E2P_DATA(0x18)
 
-#define E2P_PHY_REG		E2P_REG(0x1a)
-#define E2P_DEVICE_VER		E2P_REG(0x20)
-#define E2P_36M_CAL_VALUE1	E2P_REG(0x28)
-#define E2P_36M_CAL_VALUE2      E2P_REG(0x2a)
-#define E2P_36M_CAL_VALUE3      E2P_REG(0x2c)
-#define E2P_36M_CAL_VALUE4	E2P_REG(0x2e)
-#define E2P_11A_INT_VALUE1	E2P_REG(0x30)
-#define E2P_11A_INT_VALUE2	E2P_REG(0x32)
-#define E2P_11A_INT_VALUE3	E2P_REG(0x34)
-#define E2P_11A_INT_VALUE4	E2P_REG(0x36)
-#define E2P_48M_CAL_VALUE1	E2P_REG(0x38)
-#define E2P_48M_CAL_VALUE2	E2P_REG(0x3a)
-#define E2P_48M_CAL_VALUE3	E2P_REG(0x3c)
-#define E2P_48M_CAL_VALUE4	E2P_REG(0x3e)
-#define E2P_48M_INT_VALUE1	E2P_REG(0x40)
-#define E2P_48M_INT_VALUE2	E2P_REG(0x42)
-#define E2P_48M_INT_VALUE3	E2P_REG(0x44)
-#define E2P_48M_INT_VALUE4	E2P_REG(0x46)
-#define E2P_54M_CAL_VALUE1	E2P_REG(0x48)	/* ??? */
-#define E2P_54M_CAL_VALUE2	E2P_REG(0x4a)
-#define E2P_54M_CAL_VALUE3	E2P_REG(0x4c)
-#define E2P_54M_CAL_VALUE4	E2P_REG(0x4e)
-#define E2P_54M_INT_VALUE1	E2P_REG(0x50)
-#define E2P_54M_INT_VALUE2	E2P_REG(0x52)
-#define E2P_54M_INT_VALUE3	E2P_REG(0x54)
-#define E2P_54M_INT_VALUE4	E2P_REG(0x56)
+#define E2P_PHY_REG		E2P_DATA(0x1a)
+#define E2P_DEVICE_VER		E2P_DATA(0x20)
+#define E2P_36M_CAL_VALUE1	E2P_DATA(0x28)
+#define E2P_36M_CAL_VALUE2      E2P_DATA(0x2a)
+#define E2P_36M_CAL_VALUE3      E2P_DATA(0x2c)
+#define E2P_36M_CAL_VALUE4	E2P_DATA(0x2e)
+#define E2P_11A_INT_VALUE1	E2P_DATA(0x30)
+#define E2P_11A_INT_VALUE2	E2P_DATA(0x32)
+#define E2P_11A_INT_VALUE3	E2P_DATA(0x34)
+#define E2P_11A_INT_VALUE4	E2P_DATA(0x36)
+#define E2P_48M_CAL_VALUE1	E2P_DATA(0x38)
+#define E2P_48M_CAL_VALUE2	E2P_DATA(0x3a)
+#define E2P_48M_CAL_VALUE3	E2P_DATA(0x3c)
+#define E2P_48M_CAL_VALUE4	E2P_DATA(0x3e)
+#define E2P_48M_INT_VALUE1	E2P_DATA(0x40)
+#define E2P_48M_INT_VALUE2	E2P_DATA(0x42)
+#define E2P_48M_INT_VALUE3	E2P_DATA(0x44)
+#define E2P_48M_INT_VALUE4	E2P_DATA(0x46)
+#define E2P_54M_CAL_VALUE1	E2P_DATA(0x48)	/* ??? */
+#define E2P_54M_CAL_VALUE2	E2P_DATA(0x4a)
+#define E2P_54M_CAL_VALUE3	E2P_DATA(0x4c)
+#define E2P_54M_CAL_VALUE4	E2P_DATA(0x4e)
+#define E2P_54M_INT_VALUE1	E2P_DATA(0x50)
+#define E2P_54M_INT_VALUE2	E2P_DATA(0x52)
+#define E2P_54M_INT_VALUE3	E2P_DATA(0x54)
+#define E2P_54M_INT_VALUE4	E2P_DATA(0x56)
 
 /* All 16 bit values */
 #define FW_FIRMWARE_VER         FW_REG(0)
@@ -653,20 +653,33 @@
 /* 0x2 - link led on? */
 
 enum {
-	CR_BASE_OFFSET			= 0x9000,
-	FW_START_OFFSET			= 0xee00,
-	FW_BASE_ADDR_OFFSET		= FW_START_OFFSET + 0x1d,
-	EEPROM_START_OFFSET		= 0xf800,
-	EEPROM_SIZE			= 0x800, /* words */
-	LOAD_CODE_SIZE			= 0xe, /* words */
-	LOAD_VECT_SIZE			= 0x10000 - 0xfff7, /* words */
-	EEPROM_REGS_OFFSET		= LOAD_CODE_SIZE + LOAD_VECT_SIZE,
-	EEPROM_REGS_SIZE		= 0x7e, /* words */
-	E2P_BASE_OFFSET			= EEPROM_START_OFFSET +
-		                          EEPROM_REGS_OFFSET,
-};
+	/* CONTROL REGISTERS */
+	CR_START			= 0x9000,
+
+	/* FIRMWARE */
+	FW_START			= 0xee00,
 
-#define FW_REG_TABLE_ADDR	USB_ADDR(FW_START_OFFSET + 0x1d)
+	/* The word at this offset contains the base address of the FW_REG
+	 * registers */
+	FW_REGS_ADDR_OFFSET		= 0x1d,
+
+
+	/* EEPROM */
+	E2P_START			= 0xf800,
+	E2P_LEN				= 0x800,
+
+	/* EEPROM layout */
+	E2P_LOAD_CODE_LEN		= 0xe,		/* base 0xf800 */
+	E2P_LOAD_VECT_LEN		= 0x9,		/* base 0xf80e */
+	/* E2P_DATA indexes into this */
+	E2P_DATA_LEN			= 0x7e,		/* base 0xf817 */
+	E2P_BOOT_CODE_LEN		= 0x760,	/* base 0xf895 */
+	E2P_INTR_VECT_LEN		= 0xb,		/* base 0xfff5 */
+
+	/* Some precomputed offsets into the EEPROM */
+	E2P_DATA_OFFSET			= E2P_LOAD_CODE_LEN + E2P_LOAD_VECT_LEN,
+	E2P_BOOT_CODE_OFFSET		= E2P_DATA_OFFSET + E2P_DATA_LEN,
+};
 
 enum {
 	/* indices for ofdm_cal_values */
Index: linux/drivers/net/wireless/zd1211rw/zd_types.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_types.h
+++ linux/drivers/net/wireless/zd1211rw/zd_types.h
@@ -55,7 +55,7 @@ enum {
 #define ZD_NULL_ADDR    ((zd_addr_t)0)
 #define USB_REG(offset)  ZD_ADDR(USB_BASE, offset)	/* word addressing */
 #define CTL_REG(offset)  ZD_ADDR(CR_BASE, offset)	/* byte addressing */
-#define E2P_REG(offset)  ZD_ADDR(E2P_BASE, offset)	/* word addressing */
+#define E2P_DATA(offset)  ZD_ADDR(E2P_BASE, offset)	/* word addressing */
 #define FW_REG(offset)   ZD_ADDR(FW_BASE, offset)	/* word addressing */
 
 static inline zd_addr_t zd_inc_word(zd_addr_t addr)
Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -152,10 +152,10 @@ static u16 usb_addr(struct zd_usb *usb, 
 
 	switch (base) {
 	case CR_BASE:
-		offset += CR_BASE_OFFSET;
+		offset += CR_START;
 		break;
 	case E2P_BASE:
-		offset += E2P_BASE_OFFSET;
+		offset += E2P_START + E2P_DATA_OFFSET;
 		break;
 	case FW_BASE:
 		offset += usb->fw_base_offset;
@@ -297,14 +297,13 @@ static int handle_version_mismatch(struc
 	if (r)
 		goto error;
 
-	r = upload_code(udev, ur_fw->data, ur_fw->size, FW_START_OFFSET,
-		REBOOT);
+	r = upload_code(udev, ur_fw->data, ur_fw->size, FW_START, REBOOT);
 	if (r)
 		goto error;
 
-	offset = ((EEPROM_REGS_OFFSET + EEPROM_REGS_SIZE) * sizeof(u16));
+	offset = (E2P_BOOT_CODE_OFFSET * sizeof(u16));
 	r = upload_code(udev, ub_fw->data + offset, ub_fw->size - offset,
-		E2P_BASE_OFFSET + EEPROM_REGS_SIZE, REBOOT);
+		E2P_START + E2P_BOOT_CODE_OFFSET, REBOOT);
 
 	/* At this point, the vendor driver downloads the whole firmware
 	 * image, hacks around with version IDs, and uploads it again,
@@ -333,7 +332,7 @@ static int upload_firmware(struct usb_de
 	if (r)
 		goto error;
 
-	fw_bcdDevice = get_word(ub_fw->data, EEPROM_REGS_OFFSET);
+	fw_bcdDevice = get_word(ub_fw->data, E2P_DATA_OFFSET);
 
 	if (fw_bcdDevice != bcdDevice) {
 		dev_info(&udev->dev,
@@ -359,8 +358,7 @@ static int upload_firmware(struct usb_de
 	if (r)
 		goto error;
 
-	r = upload_code(udev, uph_fw->data, uph_fw->size, FW_START_OFFSET,
-		        REBOOT);
+	r = upload_code(udev, uph_fw->data, uph_fw->size, FW_START, REBOOT);
 	if (r) {
 		dev_err(&udev->dev,
 			"Could not upload firmware code uph. Error number %d\n",
@@ -899,7 +897,7 @@ int zd_usb_init_hw(struct zd_usb *usb)
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
 	r = zd_ioread16_locked(chip, &usb->fw_base_offset,
-		        USB_REG((u16)FW_BASE_ADDR_OFFSET));
+		        USB_REG(FW_START + FW_REGS_ADDR_OFFSET));
 	if (r)
 		return r;
 	dev_dbg_f(zd_usb_dev(usb), "fw_base_offset: %#06hx\n",
