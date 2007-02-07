From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH netdev#atl1 1/1] atl1: clean up extern, global scope declarations
Date: Tue, 6 Feb 2007 20:34:53 -0600
Message-ID: <20070207023453.GA2657@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, bunk@stusta.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf20aec.mail.bellsouth.net ([205.152.59.68]:59275 "EHLO
	imf20aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965282AbXBGCfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 21:35:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

atl1: move extern to header file; make some global code static

Move an extern declaration to a header file.  Make needlessly global
functions static.  Noticed by Adrian Bunk.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1.h         |    1 +
 drivers/net/atl1/atl1_ethtool.c |    2 +-
 drivers/net/atl1/atl1_hw.c      |    4 ++--
 drivers/net/atl1/atl1_main.c    |    4 +---
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index 3ff978b..b1c6034 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -38,6 +38,7 @@ void atl1_free_ring_resources(struct atl1_adapter *adapter);
 
 extern char atl1_driver_name[];
 extern char atl1_driver_version[];
+extern const struct ethtool_ops atl1_ethtool_ops;
 
 struct atl1_adapter;
 
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index 01c2348..c11c277 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -318,7 +318,7 @@ static void atl1_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending = 0;
 }
 
-static int atl1_set_ringparam (struct net_device *netdev,
+static int atl1_set_ringparam(struct net_device *netdev,
 				struct ethtool_ringparam *ring)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index a5e92e7..08b2d78 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -206,7 +206,7 @@ static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
  * get_permanent_address
  * return 0 if get valid mac address, 
  */
-int atl1_get_permanent_address(struct atl1_hw *hw)
+static int atl1_get_permanent_address(struct atl1_hw *hw)
 {
 	u32 addr[2];
 	u32 i, control;
@@ -592,7 +592,7 @@ static s32 atl1_setup_link(struct atl1_hw *hw)
 	return ret_val;
 }
 
-struct atl1_spi_flash_dev flash_table[] = {
+static struct atl1_spi_flash_dev flash_table[] = {
 /*	MFR_NAME  WRSR  READ  PRGM  WREN  WRDI  RDSR  RDID  SECTOR_ERASE CHIP_ERASE */
 	{"Atmel", 0x00, 0x03, 0x02, 0x06, 0x04, 0x05, 0x15, 0x52,        0x62},
 	{"SST",   0x01, 0x03, 0x02, 0x06, 0x04, 0x05, 0x90, 0x20,        0x60},
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 9a3fb86..6655640 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -96,8 +96,6 @@ MODULE_DESCRIPTION("Attansic 1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRIVER_VERSION);
 
-extern struct ethtool_ops atl1_ethtool_ops;
-
 /*
  * atl1_pci_tbl - PCI Device ID Table
  */
@@ -1205,7 +1203,7 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
  * atl1_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
-void atl1_irq_disable(struct atl1_adapter *adapter)
+static void atl1_irq_disable(struct atl1_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
