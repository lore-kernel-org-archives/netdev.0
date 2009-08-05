From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/3] netxen: remove unnecessary structures
Date: Wed,  5 Aug 2009 10:34:08 -0700
Message-ID: <1249493649-26336-2-git-send-email-dhananjay@netxen.com>
References: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:31976 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1750716AbZHEReL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 13:34:11 -0400
In-Reply-To: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary offsetof calulations on these structures:
netxen_board_info, netxen_user_old_info, netxen_new_user_info.

The offsets into the flash are fixed, don't need to be calculated.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h    |  167 ++----------------------------------
 drivers/net/netxen/netxen_nic_hw.c |   27 ++----
 2 files changed, 18 insertions(+), 176 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e22d086..bb4aa4f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -441,154 +441,6 @@ struct status_desc {
 #define NETXEN_BRDTYPE_P3_10G_XFP	0x0032
 #define NETXEN_BRDTYPE_P3_10G_TP	0x0080
 
-struct netxen_board_info {
-	u32 header_version;
-
-	u32 board_mfg;
-	u32 board_type;
-	u32 board_num;
-	u32 chip_id;
-	u32 chip_minor;
-	u32 chip_major;
-	u32 chip_pkg;
-	u32 chip_lot;
-
-	u32 port_mask;		/* available niu ports */
-	u32 peg_mask;		/* available pegs */
-	u32 icache_ok;		/* can we run with icache? */
-	u32 dcache_ok;		/* can we run with dcache? */
-	u32 casper_ok;
-
-	u32 mac_addr_lo_0;
-	u32 mac_addr_lo_1;
-	u32 mac_addr_lo_2;
-	u32 mac_addr_lo_3;
-
-	/* MN-related config */
-	u32 mn_sync_mode;	/* enable/ sync shift cclk/ sync shift mclk */
-	u32 mn_sync_shift_cclk;
-	u32 mn_sync_shift_mclk;
-	u32 mn_wb_en;
-	u32 mn_crystal_freq;	/* in MHz */
-	u32 mn_speed;		/* in MHz */
-	u32 mn_org;
-	u32 mn_depth;
-	u32 mn_ranks_0;		/* ranks per slot */
-	u32 mn_ranks_1;		/* ranks per slot */
-	u32 mn_rd_latency_0;
-	u32 mn_rd_latency_1;
-	u32 mn_rd_latency_2;
-	u32 mn_rd_latency_3;
-	u32 mn_rd_latency_4;
-	u32 mn_rd_latency_5;
-	u32 mn_rd_latency_6;
-	u32 mn_rd_latency_7;
-	u32 mn_rd_latency_8;
-	u32 mn_dll_val[18];
-	u32 mn_mode_reg;	/* MIU DDR Mode Register */
-	u32 mn_ext_mode_reg;	/* MIU DDR Extended Mode Register */
-	u32 mn_timing_0;	/* MIU Memory Control Timing Rgister */
-	u32 mn_timing_1;	/* MIU Extended Memory Ctrl Timing Register */
-	u32 mn_timing_2;	/* MIU Extended Memory Ctrl Timing2 Register */
-
-	/* SN-related config */
-	u32 sn_sync_mode;	/* enable/ sync shift cclk / sync shift mclk */
-	u32 sn_pt_mode;		/* pass through mode */
-	u32 sn_ecc_en;
-	u32 sn_wb_en;
-	u32 sn_crystal_freq;
-	u32 sn_speed;
-	u32 sn_org;
-	u32 sn_depth;
-	u32 sn_dll_tap;
-	u32 sn_rd_latency;
-
-	u32 mac_addr_hi_0;
-	u32 mac_addr_hi_1;
-	u32 mac_addr_hi_2;
-	u32 mac_addr_hi_3;
-
-	u32 magic;		/* indicates flash has been initialized */
-
-	u32 mn_rdimm;
-	u32 mn_dll_override;
-
-};
-
-#define FLASH_NUM_PORTS		(4)
-
-struct netxen_flash_mac_addr {
-	u32 flash_addr[32];
-};
-
-struct netxen_user_old_info {
-	u8 flash_md5[16];
-	u8 crbinit_md5[16];
-	u8 brdcfg_md5[16];
-	/* bootloader */
-	u32 bootld_version;
-	u32 bootld_size;
-	u8 bootld_md5[16];
-	/* image */
-	u32 image_version;
-	u32 image_size;
-	u8 image_md5[16];
-	/* primary image status */
-	u32 primary_status;
-	u32 secondary_present;
-
-	/* MAC address , 4 ports */
-	struct netxen_flash_mac_addr mac_addr[FLASH_NUM_PORTS];
-};
-#define FLASH_NUM_MAC_PER_PORT	32
-struct netxen_user_info {
-	u8 flash_md5[16 * 64];
-	/* bootloader */
-	u32 bootld_version;
-	u32 bootld_size;
-	/* image */
-	u32 image_version;
-	u32 image_size;
-	/* primary image status */
-	u32 primary_status;
-	u32 secondary_present;
-
-	/* MAC address , 4 ports, 32 address per port */
-	u64 mac_addr[FLASH_NUM_PORTS * FLASH_NUM_MAC_PER_PORT];
-	u32 sub_sys_id;
-	u8 serial_num[32];
-
-	/* Any user defined data */
-};
-
-/*
- * Flash Layout - new format.
- */
-struct netxen_new_user_info {
-	u8 flash_md5[16 * 64];
-	/* bootloader */
-	u32 bootld_version;
-	u32 bootld_size;
-	/* image */
-	u32 image_version;
-	u32 image_size;
-	/* primary image status */
-	u32 primary_status;
-	u32 secondary_present;
-
-	/* MAC address , 4 ports, 32 address per port */
-	u64 mac_addr[FLASH_NUM_PORTS * FLASH_NUM_MAC_PER_PORT];
-	u32 sub_sys_id;
-	u8 serial_num[32];
-
-	/* Any user defined data */
-};
-
-#define SECONDARY_IMAGE_PRESENT 0xb3b4b5b6
-#define SECONDARY_IMAGE_ABSENT	0xffffffff
-#define PRIMARY_IMAGE_GOOD	0x5a5a5a5a
-#define PRIMARY_IMAGE_BAD	0xffffffff
-
 /* Flash memory map */
 #define NETXEN_CRBINIT_START	0	/* crbinit section */
 #define NETXEN_BRDCFG_START	0x4000	/* board config */
@@ -599,28 +451,25 @@ struct netxen_new_user_info {
 #define NETXEN_PXE_START	0x3E0000	/* PXE boot rom */
 #define NETXEN_USER_START	0x3E8000	/* Firmare info */
 #define NETXEN_FIXED_START	0x3F0000	/* backup of crbinit */
+#define NETXEN_USER_START_OLD	NETXEN_PXE_START /* very old flash */
 
+#define NX_OLD_MAC_ADDR_OFFSET	(NETXEN_USER_START)
 #define NX_FW_VERSION_OFFSET	(NETXEN_USER_START+0x408)
 #define NX_FW_SIZE_OFFSET	(NETXEN_USER_START+0x40c)
+#define NX_FW_MAC_ADDR_OFFSET	(NETXEN_USER_START+0x418)
+#define NX_FW_SERIAL_NUM_OFFSET	(NETXEN_USER_START+0x81c)
 #define NX_BIOS_VERSION_OFFSET	(NETXEN_USER_START+0x83c)
+
+#define NX_HDR_VERSION_OFFSET	(NETXEN_BRDCFG_START)
+#define NX_BRDTYPE_OFFSET	(NETXEN_BRDCFG_START+0x8)
 #define NX_FW_MAGIC_OFFSET	(NETXEN_BRDCFG_START+0x128)
+
 #define NX_FW_MIN_SIZE		(0x3fffff)
 #define NX_P2_MN_ROMIMAGE	0
 #define NX_P3_CT_ROMIMAGE	1
 #define NX_P3_MN_ROMIMAGE	2
 #define NX_FLASH_ROMIMAGE	3
 
-#define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compatibility */
-
-#define NETXEN_FLASH_START		(NETXEN_CRBINIT_START)
-#define NETXEN_INIT_SECTOR		(0)
-#define NETXEN_PRIMARY_START 		(NETXEN_BOOTLD_START)
-#define NETXEN_FLASH_CRBINIT_SIZE 	(0x4000)
-#define NETXEN_FLASH_BRDCFG_SIZE 	(sizeof(struct netxen_board_info))
-#define NETXEN_FLASH_USER_SIZE		(sizeof(struct netxen_user_info)/sizeof(u32))
-#define NETXEN_FLASH_SECONDARY_SIZE 	(NETXEN_USER_START-NETXEN_SECONDARY_START)
-#define NETXEN_NUM_PRIMARY_SECTORS	(0x20)
-#define NETXEN_NUM_CONFIG_SECTORS 	(1)
 extern char netxen_nic_driver_name[];
 
 /* Number of status descriptors to handle per interrupt */
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index ddb9deb..673dcf5 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -816,18 +816,15 @@ int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 	__le32 *pmac = (__le32 *) mac;
 	u32 offset;
 
-	offset = NETXEN_USER_START +
-		offsetof(struct netxen_new_user_info, mac_addr) +
-		adapter->portnum * sizeof(u64);
+	offset = NX_FW_MAC_ADDR_OFFSET + (adapter->portnum * sizeof(u64));
 
 	if (netxen_get_flash_block(adapter, offset, sizeof(u64), pmac) == -1)
 		return -1;
 
 	if (*mac == cpu_to_le64(~0ULL)) {
 
-		offset = NETXEN_USER_START_OLD +
-			offsetof(struct netxen_user_old_info, mac_addr) +
-			adapter->portnum * sizeof(u64);
+		offset = NX_OLD_MAC_ADDR_OFFSET +
+			(adapter->portnum * sizeof(u64));
 
 		if (netxen_get_flash_block(adapter,
 					offset, sizeof(u64), pmac) == -1)
@@ -1857,13 +1854,11 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	int offset, board_type, magic, header_version;
 	struct pci_dev *pdev = adapter->pdev;
 
-	offset = NETXEN_BRDCFG_START +
-		offsetof(struct netxen_board_info, magic);
+	offset = NX_FW_MAGIC_OFFSET;
 	if (netxen_rom_fast_read(adapter, offset, &magic))
 		return -EIO;
 
-	offset = NETXEN_BRDCFG_START +
-		offsetof(struct netxen_board_info, header_version);
+	offset = NX_HDR_VERSION_OFFSET;
 	if (netxen_rom_fast_read(adapter, offset, &header_version))
 		return -EIO;
 
@@ -1875,8 +1870,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 		return -EIO;
 	}
 
-	offset = NETXEN_BRDCFG_START +
-		offsetof(struct netxen_board_info, board_type);
+	offset = NX_BRDTYPE_OFFSET;
 	if (netxen_rom_fast_read(adapter, offset, &board_type))
 		return -EIO;
 
@@ -2022,23 +2016,22 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 	u32 fw_major, fw_minor, fw_build;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	char serial_num[32];
-	int i, addr, val;
+	int i, offset, val;
 	int *ptr32;
 	struct pci_dev *pdev = adapter->pdev;
 
 	adapter->driver_mismatch = 0;
 
 	ptr32 = (int *)&serial_num;
-	addr = NETXEN_USER_START +
-	       offsetof(struct netxen_new_user_info, serial_num);
+	offset = NX_FW_SERIAL_NUM_OFFSET;
 	for (i = 0; i < 8; i++) {
-		if (netxen_rom_fast_read(adapter, addr, &val) == -1) {
+		if (netxen_rom_fast_read(adapter, offset, &val) == -1) {
 			dev_err(&pdev->dev, "error reading board info\n");
 			adapter->driver_mismatch = 1;
 			return;
 		}
 		ptr32[i] = cpu_to_le32(val);
-		addr += sizeof(u32);
+		offset += sizeof(u32);
 	}
 
 	fw_major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
-- 
1.6.0.2

