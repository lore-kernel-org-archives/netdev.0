From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 15/26] atl1: tidy up ring management
Date: Mon, 31 Dec 2007 20:22:42 -0600
Message-ID: <1199154173-4058-16-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([207.115.11.56]:64425 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbYAAC2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:16 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for null pointers and such in ring handling functions.  Make
needlessly global functions static.  Clean up some comments and indentation.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index f40cc6e..db6e76c 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -141,8 +141,7 @@ static s32 atl1_reset_hw(struct atl1_hw *hw)
 	return 0;
 }
 
-/* function about EEPROM
- *
+/*
  * check_eeprom_exist
  * return 0 if eeprom exist
  */
@@ -166,7 +165,7 @@ static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 *p_value)
 	u32 control;
 
 	if (offset & 3)
-		/* address do not align */
+		/* unaligned address */
 		return false;
 
 	iowrite32(0, hw->hw_addr + REG_VPD_DATA);
@@ -417,7 +416,7 @@ static void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
 	 * bit BitArray[hash_value]. So we figure out what register
 	 * the bit is in, read it, OR in the new bit, then write
 	 * back the new value.  The register is determined by the
-	 * upper 7 bits of the hash value and the bit within that
+	 * upper bit of the hash value, and the bits within that
 	 * register are determined by the lower 5 bits of the value.
 	 */
 	hash_reg = (hash_value >> 31) & 0x1;
@@ -439,9 +438,9 @@ static s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
 	u32 val;
 
 	val = ((u32) (phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |
-	    (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
-	    MDIO_SUP_PREAMBLE |
-	    MDIO_START | MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
+		(reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
+		MDIO_SUP_PREAMBLE | MDIO_START |
+		MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
 	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
 	ioread32(hw->hw_addr + REG_MDIO_CTRL);
 
@@ -872,7 +871,7 @@ static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
  *
  * Return 0 on success, negative on failure
  */
-s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
+static s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -987,6 +986,9 @@ static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 	unsigned long size;
 	unsigned int i;
 
+	if (!rfd_ring->buffer_info || !rfd_ring->desc)
+		return;
+
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rfd_ring->count; i++) {
 		buffer_info = &rfd_ring->buffer_info[i];
@@ -1060,7 +1062,7 @@ static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
  *
  * Free all transmit software resources
  */
-void atl1_free_ring_resources(struct atl1_adapter *adapter)
+static void atl1_free_ring_resources(struct atl1_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-- 
1.5.3.3

