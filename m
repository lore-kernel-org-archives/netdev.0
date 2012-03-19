From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] atlx: Use ETH_ALEN
Date: Sun, 18 Mar 2012 20:37:57 -0700
Message-ID: <1670f6450b7624f8aa92ef2c08c6aa0d0e5d5ef9.1332128181.git.joe@perches.com>
References: <cover.1332128181.git.joe@perches.com>
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1332128181.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need for yet another #define for this.

Convert NODE_ADDRESS_SIZE use to ETH_ALEN and remove #define.
Use memcpy instead of a loop to copy an address.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/atheros/atlx/atl2.c |   13 +++++--------
 drivers/net/ethernet/atheros/atlx/atl2.h |    5 ++---
 drivers/net/ethernet/atheros/atlx/atlx.h |    1 -
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 071f4c8..6762dc4 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -2258,7 +2258,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 	u32 Addr[2];
 	u32 i, Control;
 	u16 Register;
-	u8  EthAddr[NODE_ADDRESS_SIZE];
+	u8  EthAddr[ETH_ALEN];
 	bool KeyValid;
 
 	if (is_valid_ether_addr(hw->perm_mac_addr))
@@ -2299,7 +2299,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 		*(u16 *) &EthAddr[0] = SHORTSWAP(*(u16 *) &Addr[1]);
 
 		if (is_valid_ether_addr(EthAddr)) {
-			memcpy(hw->perm_mac_addr, EthAddr, NODE_ADDRESS_SIZE);
+			memcpy(hw->perm_mac_addr, EthAddr, ETH_ALEN);
 			return 0;
 		}
 		return 1;
@@ -2334,7 +2334,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 	*(u32 *) &EthAddr[2] = LONGSWAP(Addr[0]);
 	*(u16 *) &EthAddr[0] = SHORTSWAP(*(u16 *)&Addr[1]);
 	if (is_valid_ether_addr(EthAddr)) {
-		memcpy(hw->perm_mac_addr, EthAddr, NODE_ADDRESS_SIZE);
+		memcpy(hw->perm_mac_addr, EthAddr, ETH_ALEN);
 		return 0;
 	}
 	/* maybe MAC-address is from BIOS */
@@ -2344,7 +2344,7 @@ static int get_permanent_address(struct atl2_hw *hw)
 	*(u16 *) &EthAddr[0] = SHORTSWAP(*(u16 *) &Addr[1]);
 
 	if (is_valid_ether_addr(EthAddr)) {
-		memcpy(hw->perm_mac_addr, EthAddr, NODE_ADDRESS_SIZE);
+		memcpy(hw->perm_mac_addr, EthAddr, ETH_ALEN);
 		return 0;
 	}
 
@@ -2358,8 +2358,6 @@ static int get_permanent_address(struct atl2_hw *hw)
  */
 static s32 atl2_read_mac_addr(struct atl2_hw *hw)
 {
-	u16 i;
-
 	if (get_permanent_address(hw)) {
 		/* for test */
 		/* FIXME: shouldn't we use random_ether_addr() here? */
@@ -2371,8 +2369,7 @@ static s32 atl2_read_mac_addr(struct atl2_hw *hw)
 		hw->perm_mac_addr[5] = 0x38;
 	}
 
-	for (i = 0; i < NODE_ADDRESS_SIZE; i++)
-		hw->mac_addr[i] = hw->perm_mac_addr[i];
+	memcpy(hw->mac_addr, hw->perm_mac_addr, ETH_ALEN);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.h b/drivers/net/ethernet/atheros/atlx/atl2.h
index bf9016e..3ebe19f 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.h
+++ b/drivers/net/ethernet/atheros/atlx/atl2.h
@@ -47,7 +47,6 @@ extern int ethtool_ioctl(struct ifreq *ifr);
 
 #define PCI_COMMAND_REGISTER	PCI_COMMAND
 #define CMD_MEM_WRT_INVALIDATE	PCI_COMMAND_INVALIDATE
-#define ETH_ADDR_LEN		ETH_ALEN
 
 #define ATL2_WRITE_REG(a, reg, value) (iowrite32((value), \
 	((a)->hw_addr + (reg))))
@@ -429,8 +428,8 @@ struct atl2_hw {
 	u8 flash_vendor;
 
 	u8 dma_fairness;
-	u8 mac_addr[NODE_ADDRESS_SIZE];
-	u8 perm_mac_addr[NODE_ADDRESS_SIZE];
+	u8 mac_addr[ETH_ALEN];
+	u8 perm_mac_addr[ETH_ALEN];
 
 	/* FIXME */
 	/* bool phy_preamble_sup; */
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.h b/drivers/net/ethernet/atheros/atlx/atlx.h
index 14054b7..448f5dc 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.h
+++ b/drivers/net/ethernet/atheros/atlx/atlx.h
@@ -484,7 +484,6 @@
 
 /* For checksumming, the sum of all words in the EEPROM should equal 0xBABA */
 #define EEPROM_SUM			0xBABA
-#define NODE_ADDRESS_SIZE		6
 
 struct atlx_spi_flash_dev {
 	const char *manu_name;	/* manufacturer id */
-- 
1.7.8.111.gad25c.dirty
