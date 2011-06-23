From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 20/35] drivers/net changes for SMBIOS and System Firmware
Date: Thu, 23 Jun 2011 13:24:14 -0400
Message-ID: <20110623172414.27711.66929.sendpatchset@prarit.bos.redhat.com>
Content-Type: text/plain; charset=us-ascii
Cc: Prarit Bhargava <prarit@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net changes for SMBIOS and System Firmware

As part of the new SMBIOS and System Firmware code:

- Replace old dmi* structures and functions with new sysfw* and smbios*
structures and functions in individual drivers
- cleanup sysfw_id lookup tables
- cleanup of includes for dmi.h and mod_devicetable.h which were included in
some files that did not need them

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
---
 drivers/net/skge.c                 |   11 ++++++-----
 drivers/net/via-rhine.c            |   18 ++++++++++--------
 drivers/net/wireless/wl1251/sdio.c |    1 -
 3 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index f4be5c7..1200c53 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -43,7 +43,7 @@
 #include <linux/seq_file.h>
 #include <linux/mii.h>
 #include <linux/slab.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 #include <linux/prefetch.h>
 #include <asm/irq.h>
 
@@ -4089,12 +4089,13 @@ static struct pci_driver skge_driver = {
 	.driver.pm =	SKGE_PM_OPS,
 };
 
-static struct dmi_system_id skge_32bit_dma_boards[] = {
+static struct sysfw_id skge_32bit_dma_boards[] = {
 	{
 		.ident = "Gigabyte nForce boards",
 		.matches = {
-			DMI_MATCH(DMI_BOARD_VENDOR, "Gigabyte Technology Co"),
-			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
+			SYSFW_MATCH(SYSFW_BOARD_VENDOR,
+				     "Gigabyte Technology Co"),
+			SYSFW_MATCH(SYSFW_BOARD_NAME, "nForce"),
 		},
 	},
 	{}
@@ -4102,7 +4103,7 @@ static struct dmi_system_id skge_32bit_dma_boards[] = {
 
 static int __init skge_init_module(void)
 {
-	if (dmi_check_system(skge_32bit_dma_boards))
+	if (sysfw_callback(skge_32bit_dma_boards))
 		only_32bit_dma = 1;
 	skge_debug_init();
 	return pci_register_driver(&skge_driver);
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 7f23ab9..81725d5 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -110,7 +110,7 @@ static const int multicast_filter_limit = 32;
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
-#include <linux/dmi.h>
+#include <linux/sysfw.h>
 
 /* These identify the driver base version and may not be removed. */
 static const char version[] __devinitconst =
@@ -2294,22 +2294,24 @@ static struct pci_driver rhine_driver = {
 	.shutdown =	rhine_shutdown,
 };
 
-static struct dmi_system_id __initdata rhine_dmi_table[] = {
+static struct sysfw_id __initdata rhine_id_table[] = {
 	{
 		.ident = "EPIA-M",
 		.matches = {
-			DMI_MATCH(DMI_BIOS_VENDOR, "Award Software International, Inc."),
-			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Award Software International, Inc."),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "6.00 PG"),
 		},
 	},
 	{
 		.ident = "KV7",
 		.matches = {
-			DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies, LTD"),
-			DMI_MATCH(DMI_BIOS_VERSION, "6.00 PG"),
+			SYSFW_MATCH(SYSFW_BIOS_VENDOR,
+				    "Phoenix Technologies, LTD"),
+			SYSFW_MATCH(SYSFW_BIOS_VERSION, "6.00 PG"),
 		},
 	},
-	{ NULL }
+	{}
 };
 
 static int __init rhine_init(void)
@@ -2318,7 +2320,7 @@ static int __init rhine_init(void)
 #ifdef MODULE
 	pr_info("%s\n", version);
 #endif
-	if (dmi_check_system(rhine_dmi_table)) {
+	if (sysfw_callback(rhine_id_table)) {
 		/* these BIOSes fail at PXE boot if chip is in D3 */
 		avoid_D3 = 1;
 		pr_warn("Broken BIOS detected, avoid_D3 enabled\n");
diff --git a/drivers/net/wireless/wl1251/sdio.c b/drivers/net/wireless/wl1251/sdio.c
index f51a024..68e36d7 100644
--- a/drivers/net/wireless/wl1251/sdio.c
+++ b/drivers/net/wireless/wl1251/sdio.c
@@ -20,7 +20,6 @@
  * Copyright (C) 2009 Bob Copeland (me@bobcopeland.com)
  */
 #include <linux/module.h>
-#include <linux/mod_devicetable.h>
 #include <linux/mmc/sdio_func.h>
 #include <linux/mmc/sdio_ids.h>
 #include <linux/platform_device.h>
-- 
1.7.5.4
