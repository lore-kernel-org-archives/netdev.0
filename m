From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 3/5] NetXen: Add NETXEN prefix to macros
Date: Fri, 1 Jun 2007 04:15:36 -0700
Message-ID: <200706011115.l51BFahX004752@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:20218 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755681AbXFALPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 07:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Add NETXEN prefix to a macro
This patch will add the "NETXEN" prefix to "USER_START" macro.

Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic.h         |    4 ++--
 drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
 drivers/net/netxen/netxen_nic_hw.c      |    4 ++--
 drivers/net/netxen/netxen_nic_init.c    |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index c74402f..6ce6e99 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -705,7 +705,7 @@ typedef enum {
 	IMAGE_START = 0x43000,	/* compressed image */
 	SECONDARY_START = 0x200000,	/* backup images */
 	PXE_START = 0x3E0000,	/* user defined region */
-	USER_START = 0x3E8000,	/* User defined region for new boards */
+	NETXEN_USER_START = 0x3E8000,	/* User defined region for new boards */
 	FIXED_START = 0x3F0000	/* backup of crbinit */
 } netxen_flash_map_t;
 
@@ -717,7 +717,7 @@ #define PRIMARY_START 		(BOOTLD_START)
 #define FLASH_CRBINIT_SIZE 	(0x4000)
 #define FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
 #define FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
-#define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
+#define FLASH_SECONDARY_SIZE 	(NETXEN_USER_START-SECONDARY_START)
 #define NUM_PRIMARY_SECTORS	(0x20)
 #define NUM_CONFIG_SECTORS 	(1)
 #define PFX "NetXen: "
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 16fabb3..f7ddcd0 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -478,7 +478,7 @@ netxen_nic_set_eeprom(struct net_device 
 			return ret;
 		}
 
-		ret = netxen_rom_se(adapter, USER_START);
+		ret = netxen_rom_se(adapter, NETXEN_USER_START);
 		if (ret != FLASH_SUCCESS)
 			return ret;
 		ret = netxen_rom_se(adapter, FIXED_START);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index fff3844..ef964b4 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -720,7 +720,7 @@ int netxen_get_flash_mac_addr(struct net
 	u32 *pmac = (u32 *) & mac[0];
 
 	if (netxen_get_flash_block(adapter,
-				   USER_START +
+				   NETXEN_USER_START +
 				   offsetof(struct netxen_new_user_info,
 					    mac_addr),
 				   FLASH_NUM_PORTS * sizeof(u64), pmac) == -1) {
@@ -1224,7 +1224,7 @@ void netxen_nic_flash_print(struct netxe
 	u32 fw_build = 0;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	struct netxen_new_user_info user_info;
-	int i, addr = USER_START;
+	int i, addr = NETXEN_USER_START;
 	__le32 *ptr32;
 
 	struct netxen_board_info *board_info = &(adapter->ahw.boardcfg);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index a368924..ac93987 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -654,7 +654,7 @@ void check_erased_flash(struct netxen_ad
 	int count = 0, erased_errors = 0;
 	int range;
 
-	range = (addr == USER_START) ? FIXED_START : addr + FLASH_SECTOR_SIZE;
+	range = (addr == NETXEN_USER_START) ? FIXED_START : addr + FLASH_SECTOR_SIZE;
 	
 	for (i = addr; i < range; i += 4) {
 		netxen_rom_fast_read(adapter, i, &val);
@@ -707,7 +707,7 @@ netxen_flash_erase_secondary(struct netx
 	int start, end;
 
 	start = SECONDARY_START / FLASH_SECTOR_SIZE;
-	end   = USER_START / FLASH_SECTOR_SIZE;
+	end   = NETXEN_USER_START / FLASH_SECTOR_SIZE;
 	ret = netxen_flash_erase_sections(adapter, start, end);
 
 	return ret;
