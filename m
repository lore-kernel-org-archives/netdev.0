From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/12] atlx: make local functions/data static
Date: Thu, 21 Oct 2010 10:50:50 -0700
Message-ID: <20101021175148.404042175@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36317 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756405Ab0JUSBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:06 -0400
Content-Disposition: inline; filename=atlx_local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/atlx/atl1.c |   12 +++++++-----
 drivers/net/atlx/atl1.h |    9 +++------
 drivers/net/atlx/atlx.c |    4 ++++
 3 files changed, 14 insertions(+), 11 deletions(-)

--- a/drivers/net/atlx/atl1.c	2010-10-21 08:50:30.597051580 -0700
+++ b/drivers/net/atlx/atl1.c	2010-10-21 08:52:01.833715425 -0700
@@ -91,6 +91,8 @@ MODULE_VERSION(ATLX_DRIVER_VERSION);
 /* Temporary hack for merging atl1 and atl2 */
 #include "atlx.c"
 
+static const struct ethtool_ops atl1_ethtool_ops;
+
 /*
  * This is the only thing that needs to be changed to adjust the
  * maximum number of ports that the driver can manage.
@@ -353,7 +355,7 @@ static bool atl1_read_eeprom(struct atl1
  * hw - Struct containing variables accessed by shared code
  * reg_addr - address of the PHY register to read
  */
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
+static s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
 {
 	u32 val;
 	int i;
@@ -553,7 +555,7 @@ static s32 atl1_read_mac_addr(struct atl
  *          1. calcu 32bit CRC for multicast address
  *          2. reverse crc with MSB to LSB
  */
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
+static u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
 {
 	u32 crc32, value = 0;
 	int i;
@@ -570,7 +572,7 @@ u32 atl1_hash_mc_addr(struct atl1_hw *hw
  * hw - Struct containing variables accessed by shared code
  * hash_value - Multicast address hash value
  */
-void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
+static void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
 {
 	u32 hash_bit, hash_reg;
 	u32 mta;
@@ -914,7 +916,7 @@ static s32 atl1_get_speed_and_duplex(str
 	return 0;
 }
 
-void atl1_set_mac_addr(struct atl1_hw *hw)
+static void atl1_set_mac_addr(struct atl1_hw *hw)
 {
 	u32 value;
 	/*
@@ -3658,7 +3660,7 @@ static int atl1_nway_reset(struct net_de
 	return 0;
 }
 
-const struct ethtool_ops atl1_ethtool_ops = {
+static const struct ethtool_ops atl1_ethtool_ops = {
 	.get_settings		= atl1_get_settings,
 	.set_settings		= atl1_set_settings,
 	.get_drvinfo		= atl1_get_drvinfo,
--- a/drivers/net/atlx/atl1.h	2010-10-21 08:50:30.613053116 -0700
+++ b/drivers/net/atlx/atl1.h	2010-10-21 08:52:01.833715425 -0700
@@ -56,16 +56,13 @@ struct atl1_adapter;
 struct atl1_hw;
 
 /* function prototypes needed by multiple files */
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
-void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data);
-void atl1_set_mac_addr(struct atl1_hw *hw);
+static u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
+static void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
+static void atl1_set_mac_addr(struct atl1_hw *hw);
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	int cmd);
 static u32 atl1_check_link(struct atl1_adapter *adapter);
 
-extern const struct ethtool_ops atl1_ethtool_ops;
-
 /* hardware definitions specific to L1 */
 
 /* Block IDLE Status Register */
--- a/drivers/net/atlx/atlx.c	2010-10-21 08:50:30.637055420 -0700
+++ b/drivers/net/atlx/atlx.c	2010-10-21 08:52:01.837715801 -0700
@@ -41,6 +41,10 @@
 
 #include "atlx.h"
 
+static s32 atlx_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data);
+static u32 atlx_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
+static void atlx_set_mac_addr(struct atl1_hw *hw);
+
 static struct atlx_spi_flash_dev flash_table[] = {
 /*	MFR_NAME  WRSR  READ  PRGM  WREN  WRDI  RDSR  RDID  SEC_ERS CHIP_ERS */
 	{"Atmel", 0x00, 0x03, 0x02, 0x06, 0x04, 0x05, 0x15, 0x52,   0x62},


