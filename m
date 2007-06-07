From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 4/4] NetXen: Fix compile failure seen on PPC architecture
Date: Thu, 7 Jun 2007 04:36:36 -0700
Message-ID: <200706071136.l57Baauh007637@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:9394 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753692AbXFGLgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 07:36:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Add NETXEN prefixes to macros to clean them up.
This is a cleanup patch which adds NETXEN prefix to some stand 
alone macro names.
These posed compile errors when NetXen driver was backported to 2.6.9
on PPC architecture as macros like USER_START are defined in file
arch/ppc64/mm/hash_utils.c

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
Acked-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic.h         |   47 +++++++++++-----------
 drivers/net/netxen/netxen_nic_ethtool.c |    8 +--
 drivers/net/netxen/netxen_nic_hw.c      |   12 ++---
 drivers/net/netxen/netxen_nic_init.c    |   23 +++++-----
 4 files changed, 46 insertions(+), 44 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2fddfd1..0eb80ed 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -68,9 +68,10 @@ #define _NETXEN_NIC_LINUX_MINOR 4
 #define _NETXEN_NIC_LINUX_SUBVERSION 2
 #define NETXEN_NIC_LINUX_VERSIONID  "3.4.2"
 
-#define NUM_FLASH_SECTORS (64)
-#define FLASH_SECTOR_SIZE (64 * 1024)
-#define FLASH_TOTAL_SIZE  (NUM_FLASH_SECTORS * FLASH_SECTOR_SIZE)
+#define NETXEN_NUM_FLASH_SECTORS (64)
+#define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)
+#define NETXEN_FLASH_TOTAL_SIZE  (NETXEN_NUM_FLASH_SECTORS \
+					* NETXEN_FLASH_SECTOR_SIZE)
 
 #define PHAN_VENDOR_ID 0x4040
 
@@ -698,28 +699,28 @@ #define PRIMARY_IMAGE_BAD	0xffffffff
 
 /* Flash memory map */
 typedef enum {
-	CRBINIT_START = 0,	/* Crbinit section */
-	BRDCFG_START = 0x4000,	/* board config */
-	INITCODE_START = 0x6000,	/* pegtune code */
-	BOOTLD_START = 0x10000,	/* bootld */
-	IMAGE_START = 0x43000,	/* compressed image */
-	SECONDARY_START = 0x200000,	/* backup images */
-	PXE_START = 0x3E0000,	/* user defined region */
-	USER_START = 0x3E8000,	/* User defined region for new boards */
-	FIXED_START = 0x3F0000	/* backup of crbinit */
+	NETXEN_CRBINIT_START = 0,	/* Crbinit section */
+	NETXEN_BRDCFG_START = 0x4000,	/* board config */
+	NETXEN_INITCODE_START = 0x6000,	/* pegtune code */
+	NETXEN_BOOTLD_START = 0x10000,	/* bootld */
+	NETXEN_IMAGE_START = 0x43000,	/* compressed image */
+	NETXEN_SECONDARY_START = 0x200000,	/* backup images */
+	NETXEN_PXE_START = 0x3E0000,	/* user defined region */
+	NETXEN_USER_START = 0x3E8000,	/* User defined region for new boards */
+	NETXEN_FIXED_START = 0x3F0000	/* backup of crbinit */
 } netxen_flash_map_t;
 
-#define USER_START_OLD PXE_START	/* for backward compatibility */
-
-#define FLASH_START		(CRBINIT_START)
-#define INIT_SECTOR		(0)
-#define PRIMARY_START 		(BOOTLD_START)
-#define FLASH_CRBINIT_SIZE 	(0x4000)
-#define FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
-#define FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
-#define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
-#define NUM_PRIMARY_SECTORS	(0x20)
-#define NUM_CONFIG_SECTORS 	(1)
+#define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compatibility */
+
+#define NETXEN_FLASH_START		(NETXEN_CRBINIT_START)
+#define NETXEN_INIT_SECTOR		(0)
+#define NETXEN_PRIMARY_START 		(NETXEN_BOOTLD_START)
+#define NETXEN_FLASH_CRBINIT_SIZE 	(0x4000)
+#define NETXEN_FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
+#define NETXEN_FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
+#define NETXEN_FLASH_SECONDARY_SIZE 	(NETXEN_USER_START-NETXEN_SECONDARY_START)
+#define NETXEN_NUM_PRIMARY_SECTORS	(0x20)
+#define NETXEN_NUM_CONFIG_SECTORS 	(1)
 #define PFX "NetXen: "
 extern char netxen_nic_driver_name[];
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 16fabb3..0175f6c 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -94,7 +94,7 @@ #define NETXEN_MAX_EEPROM_LEN   1024
 
 static int netxen_nic_get_eeprom_len(struct net_device *dev)
 {
-	return FLASH_TOTAL_SIZE;
+	return NETXEN_FLASH_TOTAL_SIZE;
 }
 
 static void
@@ -470,7 +470,7 @@ netxen_nic_set_eeprom(struct net_device 
 		return 0;
 	}
 
-	if (offset == BOOTLD_START) {
+	if (offset == NETXEN_BOOTLD_START) {
 		ret = netxen_flash_erase_primary(adapter);
 		if (ret != FLASH_SUCCESS) {
 			printk(KERN_ERR "%s: Flash erase failed.\n", 
@@ -478,10 +478,10 @@ netxen_nic_set_eeprom(struct net_device 
 			return ret;
 		}
 
-		ret = netxen_rom_se(adapter, USER_START);
+		ret = netxen_rom_se(adapter, NETXEN_USER_START);
 		if (ret != FLASH_SUCCESS)
 			return ret;
-		ret = netxen_rom_se(adapter, FIXED_START);
+		ret = netxen_rom_se(adapter, NETXEN_FIXED_START);
 		if (ret != FLASH_SUCCESS)
 			return ret;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c5d4ff9..8a6e5e6 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -257,7 +257,7 @@ u64 ctx_addr_sig_regs[][3] = {
 #define ADDR_IN_RANGE(addr, low, high)	\
 	(((addr) <= (high)) && ((addr) >= (low)))
 
-#define NETXEN_FLASH_BASE	(BOOTLD_START)
+#define NETXEN_FLASH_BASE	(NETXEN_BOOTLD_START)
 #define NETXEN_PHANTOM_MEM_BASE	(NETXEN_FLASH_BASE)
 #define NETXEN_MAX_MTU		8000 + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE
 #define NETXEN_MIN_MTU		64
@@ -724,7 +724,7 @@ int netxen_get_flash_mac_addr(struct net
 	u32 *pmac = (u32 *) & mac[0];
 
 	if (netxen_get_flash_block(adapter,
-				   USER_START +
+				   NETXEN_USER_START +
 				   offsetof(struct netxen_new_user_info,
 					    mac_addr),
 				   FLASH_NUM_PORTS * sizeof(u64), pmac) == -1) {
@@ -732,7 +732,7 @@ int netxen_get_flash_mac_addr(struct net
 	}
 	if (*mac == ~0ULL) {
 		if (netxen_get_flash_block(adapter,
-					   USER_START_OLD +
+					   NETXEN_USER_START_OLD +
 					   offsetof(struct netxen_user_old_info,
 						    mac_addr),
 					   FLASH_NUM_PORTS * sizeof(u64),
@@ -1055,7 +1055,7 @@ netxen_nic_pci_set_window(struct netxen_
 int
 netxen_nic_erase_pxe(struct netxen_adapter *adapter)
 {
-	if (netxen_rom_fast_write(adapter, PXE_START, 0) == -1) {
+	if (netxen_rom_fast_write(adapter, NETXEN_PXE_START, 0) == -1) {
 		printk(KERN_ERR "%s: erase pxe failed\n", 
 			netxen_nic_driver_name);
 		return -1;
@@ -1066,7 +1066,7 @@ netxen_nic_erase_pxe(struct netxen_adapt
 int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 {
 	int rv = 0;
-	int addr = BRDCFG_START;
+	int addr = NETXEN_BRDCFG_START;
 	struct netxen_board_info *boardinfo;
 	int index;
 	u32 *ptr32;
@@ -1228,7 +1228,7 @@ void netxen_nic_flash_print(struct netxe
 	u32 fw_build = 0;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	struct netxen_new_user_info user_info;
-	int i, addr = USER_START;
+	int i, addr = NETXEN_USER_START;
 	__le32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 0446d13..7d0b5b0 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -585,7 +585,7 @@ int netxen_backup_crbinit(struct netxen_
 {
 	int ret = FLASH_SUCCESS;
 	int val;
-	char *buffer = kmalloc(FLASH_SECTOR_SIZE, GFP_KERNEL);
+	char *buffer = kmalloc(NETXEN_FLASH_SECTOR_SIZE, GFP_KERNEL);
 
 	if (!buffer)
 		return -ENOMEM;	
@@ -601,13 +601,13 @@ int netxen_backup_crbinit(struct netxen_
 		goto out_kfree;
 
 	/* copy  sector 0 to sector 63 */
-	ret = netxen_rom_fast_read_words(adapter, CRBINIT_START, 
-						buffer, FLASH_SECTOR_SIZE);
+	ret = netxen_rom_fast_read_words(adapter, NETXEN_CRBINIT_START, 
+					buffer, NETXEN_FLASH_SECTOR_SIZE);
 	if (ret != FLASH_SUCCESS)
 		goto out_kfree;
 
-	ret = netxen_rom_fast_write_words(adapter, FIXED_START, 
-						buffer, FLASH_SECTOR_SIZE);
+	ret = netxen_rom_fast_write_words(adapter, NETXEN_FIXED_START, 
+					buffer, NETXEN_FLASH_SECTOR_SIZE);
 	if (ret != FLASH_SUCCESS)
 		goto out_kfree;
 
@@ -654,7 +654,8 @@ void check_erased_flash(struct netxen_ad
 	int count = 0, erased_errors = 0;
 	int range;
 
-	range = (addr == USER_START) ? FIXED_START : addr + FLASH_SECTOR_SIZE;
+	range = (addr == NETXEN_USER_START) ? 
+		NETXEN_FIXED_START : addr + NETXEN_FLASH_SECTOR_SIZE;
 	
 	for (i = addr; i < range; i += 4) {
 		netxen_rom_fast_read(adapter, i, &val);
@@ -689,7 +690,7 @@ netxen_flash_erase_sections(struct netxe
 	int i;
 
 	for (i = start; i < end; i++) {
-		ret = netxen_rom_se(adapter, i * FLASH_SECTOR_SIZE);
+		ret = netxen_rom_se(adapter, i * NETXEN_FLASH_SECTOR_SIZE);
 		if (ret)
 			break;
 		ret = netxen_rom_wip_poll(adapter);
@@ -706,8 +707,8 @@ netxen_flash_erase_secondary(struct netx
 	int ret = FLASH_SUCCESS;
 	int start, end;
 
-	start = SECONDARY_START / FLASH_SECTOR_SIZE;
-	end   = USER_START / FLASH_SECTOR_SIZE;
+	start = NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
+	end   = NETXEN_USER_START / NETXEN_FLASH_SECTOR_SIZE;
 	ret = netxen_flash_erase_sections(adapter, start, end);
 
 	return ret;
@@ -719,8 +720,8 @@ netxen_flash_erase_primary(struct netxen
 	int ret = FLASH_SUCCESS;
 	int start, end;
 
-	start = PRIMARY_START / FLASH_SECTOR_SIZE;
-	end   = SECONDARY_START / FLASH_SECTOR_SIZE;
+	start = NETXEN_PRIMARY_START / NETXEN_FLASH_SECTOR_SIZE;
+	end   = NETXEN_SECONDARY_START / NETXEN_FLASH_SECTOR_SIZE;
 	ret = netxen_flash_erase_sections(adapter, start, end);
 
 	return ret;
