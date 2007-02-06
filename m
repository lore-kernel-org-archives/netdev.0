From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: -mm patch] drivers/net/atl1/: possible cleanups
Date: Tue, 6 Feb 2007 23:12:29 +0100
Message-ID: <20070206221229.GH27397@stusta.de>
References: <20070129204528.eb8d695e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>,
	Xiong Huang <xiong_huang@attansic.com>,
	Chris Snook <csnook@redhat.com>,
	Jay Cliburn <jcliburn@gmail.com>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:39713 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965559AbXBFWMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:12:25 -0500
Content-Disposition: inline
In-Reply-To: <20070129204528.eb8d695e.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 08:45:28PM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.20-rc6-mm2:
>...
>  git-netdev-all.patch
>...
>  git trees
>...


This patch contains the following possible cleanups:
- move extern declarations to atl1.h
- make needlessly global code static

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

BTW: Can we get a MAINTAINERS entry for this driver?

 drivers/net/atl1/atl1.h         |    6 ++++--
 drivers/net/atl1/atl1_ethtool.c |    3 ---
 drivers/net/atl1/atl1_hw.c      |    6 ++----
 drivers/net/atl1/atl1_main.c    |    8 +++-----
 drivers/net/atl1/atl1_param.c   |    4 +---
 5 files changed, 10 insertions(+), 17 deletions(-)

--- linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1.h.old	2007-02-06 07:55:58.000000000 +0100
+++ linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1.h	2007-02-06 08:19:50.000000000 +0100
@@ -34,8 +34,10 @@
 s32 atl1_up(struct atl1_adapter *adapter);
 void atl1_down(struct atl1_adapter *adapter);
 int atl1_reset(struct atl1_adapter *adapter);
-s32 atl1_setup_ring_resources(struct atl1_adapter *adapter);
-void atl1_free_ring_resources(struct atl1_adapter *adapter);
+
+extern char atl1_driver_name[];
+extern char atl1_driver_version[];
+extern const struct ethtool_ops atl1_ethtool_ops;
 
 struct atl1_adapter;
 
--- linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_hw.c.old	2007-02-06 07:52:20.000000000 +0100
+++ linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_hw.c	2007-02-06 07:56:22.000000000 +0100
@@ -31,8 +31,6 @@
 #include "atl1.h"
 
 
-extern char atl1_driver_name[];
-
 /**
  * Reset the transmit and receive units; mask and clear all interrupts.
  * hw - Struct containing variables accessed by shared code
@@ -209,7 +207,7 @@
  * get_permanent_address
  * return 0 if get valid mac address, 
  **/
-int atl1_get_permanent_address(struct atl1_hw *hw)
+static int atl1_get_permanent_address(struct atl1_hw *hw)
 {
 	u32 addr[2];
 	u32 i, control;
@@ -602,7 +600,7 @@
 	return ret_val;
 }
 
-struct atl1_spi_flash_dev flash_table[] = {
+static struct atl1_spi_flash_dev flash_table[] = {
 /*	MFR_NAME  WRSR  READ  PRGM  WREN  WRDI  RDSR  RDID  SECTOR_ERASE CHIP_ERASE */
 	{"Atmel", 0x00, 0x03, 0x02, 0x06, 0x04, 0x05, 0x15, 0x52,        0x62},
 	{"SST",   0x01, 0x03, 0x02, 0x06, 0x04, 0x05, 0x90, 0x20,        0x60},
--- linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_ethtool.c.old	2007-02-06 07:57:04.000000000 +0100
+++ linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_ethtool.c	2007-02-06 07:57:10.000000000 +0100
@@ -31,9 +31,6 @@
 #include "atl1.h"
 
 
-extern char atl1_driver_name[];
-extern char atl1_driver_version[];
-
 struct atl1_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
--- linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_param.c.old	2007-02-06 07:57:18.000000000 +0100
+++ linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_param.c	2007-02-06 08:16:39.000000000 +0100
@@ -26,8 +26,6 @@
 #include <linux/moduleparam.h>
 #include "atl1.h"
 
-extern char atl1_driver_name[];
-
 /**
  * This is the only thing that needs to be changed to adjust the
  * maximum number of ports that the driver can manage.
@@ -68,7 +66,7 @@
 module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_vendor, 0);
 MODULE_PARM_DESC(flash_vendor, "SPI flash vendor");
 
-int enable_msi;
+static int enable_msi;
 module_param(enable_msi, int, 0444);
 MODULE_PARM_DESC(enable_msi, "Enable PCI MSI");
 
--- linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_main.c.old	2007-02-06 07:58:37.000000000 +0100
+++ linux-2.6.20-rc6-mm3/drivers/net/atl1/atl1_main.c	2007-02-06 08:15:51.000000000 +0100
@@ -95,8 +95,6 @@
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRIVER_VERSION);
 
-extern struct ethtool_ops atl1_ethtool_ops;
-
 /**
  * atl1_pci_tbl - PCI Device ID Table
  **/
@@ -178,7 +176,7 @@
  *
  * Return 0 on success, negative on failure
  **/
-s32 atl1_setup_ring_resources(struct atl1_adapter * adapter)
+static s32 atl1_setup_ring_resources(struct atl1_adapter * adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -1221,7 +1219,7 @@
  * atl1_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  **/
-void atl1_irq_disable(struct atl1_adapter *adapter)
+static void atl1_irq_disable(struct atl1_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
@@ -1749,7 +1747,7 @@
  *
  * Free all transmit software resources
  **/
-void atl1_free_ring_resources(struct atl1_adapter *adapter)
+static void atl1_free_ring_resources(struct atl1_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;

