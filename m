From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/7] be2net: move definitions related to FW cmdsfrom be_hw.h to be_cmds.h
Date: Tue, 20 Jan 2015 03:51:48 -0500
Message-ID: <1421743909-14716-7-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:11712 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbbATItI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:49:08 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Some FW cmd related definitions were included in be_hw.h

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h | 175 ++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_hw.h   | 223 ----------------------------
 drivers/net/ethernet/emulex/benet/be_main.c |   2 +-
 3 files changed, 176 insertions(+), 224 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index eb5085d..c2701cc 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1161,7 +1161,167 @@ struct be_cmd_resp_get_beacon_state {
 	u8 rsvd0[3];
 } __packed;
 
+/* Flashrom related descriptors */
+#define MAX_FLASH_COMP			32
+
+#define OPTYPE_ISCSI_ACTIVE		0
+#define OPTYPE_REDBOOT			1
+#define OPTYPE_BIOS			2
+#define OPTYPE_PXE_BIOS			3
+#define OPTYPE_FCOE_BIOS		8
+#define OPTYPE_ISCSI_BACKUP		9
+#define OPTYPE_FCOE_FW_ACTIVE		10
+#define OPTYPE_FCOE_FW_BACKUP		11
+#define OPTYPE_NCSI_FW			13
+#define OPTYPE_REDBOOT_DIR		18
+#define OPTYPE_REDBOOT_CONFIG		19
+#define OPTYPE_SH_PHY_FW		21
+#define OPTYPE_FLASHISM_JUMPVECTOR	22
+#define OPTYPE_UFI_DIR			23
+#define OPTYPE_PHY_FW			99
+
+#define FLASH_BIOS_IMAGE_MAX_SIZE_g2	262144  /* Max OPTION ROM image sz */
+#define FLASH_REDBOOT_IMAGE_MAX_SIZE_g2	262144  /* Max Redboot image sz    */
+#define FLASH_IMAGE_MAX_SIZE_g2		1310720 /* Max firmware image size */
+
+#define FLASH_NCSI_IMAGE_MAX_SIZE_g3	262144
+#define FLASH_PHY_FW_IMAGE_MAX_SIZE_g3	262144
+#define FLASH_BIOS_IMAGE_MAX_SIZE_g3	524288  /* Max OPTION ROM image sz */
+#define FLASH_REDBOOT_IMAGE_MAX_SIZE_g3	1048576 /* Max Redboot image sz    */
+#define FLASH_IMAGE_MAX_SIZE_g3		2097152 /* Max firmware image size */
+
+/* Offsets for components on Flash. */
+#define FLASH_REDBOOT_START_g2			0
+#define FLASH_FCoE_BIOS_START_g2		524288
+#define FLASH_iSCSI_PRIMARY_IMAGE_START_g2	1048576
+#define FLASH_iSCSI_BACKUP_IMAGE_START_g2	2359296
+#define FLASH_FCoE_PRIMARY_IMAGE_START_g2	3670016
+#define FLASH_FCoE_BACKUP_IMAGE_START_g2	4980736
+#define FLASH_iSCSI_BIOS_START_g2		7340032
+#define FLASH_PXE_BIOS_START_g2			7864320
+
+#define FLASH_REDBOOT_START_g3			262144
+#define FLASH_PHY_FW_START_g3			1310720
+#define FLASH_iSCSI_PRIMARY_IMAGE_START_g3	2097152
+#define FLASH_iSCSI_BACKUP_IMAGE_START_g3	4194304
+#define FLASH_FCoE_PRIMARY_IMAGE_START_g3	6291456
+#define FLASH_FCoE_BACKUP_IMAGE_START_g3	8388608
+#define FLASH_iSCSI_BIOS_START_g3		12582912
+#define FLASH_PXE_BIOS_START_g3			13107200
+#define FLASH_FCoE_BIOS_START_g3		13631488
+#define FLASH_NCSI_START_g3			15990784
+
+#define IMAGE_NCSI			16
+#define IMAGE_OPTION_ROM_PXE		32
+#define IMAGE_OPTION_ROM_FCoE		33
+#define IMAGE_OPTION_ROM_ISCSI		34
+#define IMAGE_FLASHISM_JUMPVECTOR	48
+#define IMAGE_FIRMWARE_iSCSI		160
+#define IMAGE_FIRMWARE_FCoE		162
+#define IMAGE_FIRMWARE_BACKUP_iSCSI	176
+#define IMAGE_FIRMWARE_BACKUP_FCoE	178
+#define IMAGE_FIRMWARE_PHY		192
+#define IMAGE_REDBOOT_DIR		208
+#define IMAGE_REDBOOT_CONFIG		209
+#define IMAGE_UFI_DIR			210
+#define IMAGE_BOOT_CODE			224
+
+struct controller_id {
+	u32 vendor;
+	u32 device;
+	u32 subvendor;
+	u32 subdevice;
+};
+
+struct flash_comp {
+	unsigned long offset;
+	int optype;
+	int size;
+	int img_type;
+};
+
+struct image_hdr {
+	u32 imageid;
+	u32 imageoffset;
+	u32 imagelength;
+	u32 image_checksum;
+	u8 image_version[32];
+};
+
+struct flash_file_hdr_g2 {
+	u8 sign[32];
+	u32 cksum;
+	u32 antidote;
+	struct controller_id cont_id;
+	u32 file_len;
+	u32 chunk_num;
+	u32 total_chunks;
+	u32 num_imgs;
+	u8 build[24];
+};
+
+struct flash_file_hdr_g3 {
+	u8 sign[52];
+	u8 ufi_version[4];
+	u32 file_len;
+	u32 cksum;
+	u32 antidote;
+	u32 num_imgs;
+	u8 build[24];
+	u8 asic_type_rev;
+	u8 rsvd[31];
+};
+
+struct flash_section_hdr {
+	u32 format_rev;
+	u32 cksum;
+	u32 antidote;
+	u32 num_images;
+	u8 id_string[128];
+	u32 rsvd[4];
+} __packed;
+
+struct flash_section_hdr_g2 {
+	u32 format_rev;
+	u32 cksum;
+	u32 antidote;
+	u32 build_num;
+	u8 id_string[128];
+	u32 rsvd[8];
+} __packed;
+
+struct flash_section_entry {
+	u32 type;
+	u32 offset;
+	u32 pad_size;
+	u32 image_size;
+	u32 cksum;
+	u32 entry_point;
+	u16 optype;
+	u16 rsvd0;
+	u32 rsvd1;
+	u8 ver_data[32];
+} __packed;
+
+struct flash_section_info {
+	u8 cookie[32];
+	struct flash_section_hdr fsec_hdr;
+	struct flash_section_entry fsec_entry[32];
+} __packed;
+
+struct flash_section_info_g2 {
+	u8 cookie[32];
+	struct flash_section_hdr_g2 fsec_hdr;
+	struct flash_section_entry fsec_entry[32];
+} __packed;
+
 /****************** Firmware Flash ******************/
+#define FLASHROM_OPER_FLASH		1
+#define FLASHROM_OPER_SAVE		2
+#define FLASHROM_OPER_REPORT		4
+#define FLASHROM_OPER_PHY_FLASH		9
+#define FLASHROM_OPER_PHY_SAVE		10
+
 struct flashrom_params {
 	u32 op_code;
 	u32 op_type;
@@ -1366,6 +1526,7 @@ enum {
 	PHY_TYPE_QSFP,
 	PHY_TYPE_KR4_40GB,
 	PHY_TYPE_KR2_20GB,
+	PHY_TYPE_TN_8022,
 	PHY_TYPE_DISABLED = 255
 };
 
@@ -1429,6 +1590,20 @@ struct be_cmd_req_set_qos {
 };
 
 /*********************** Controller Attributes ***********************/
+struct mgmt_hba_attribs {
+	u32 rsvd0[24];
+	u8 controller_model_number[32];
+	u32 rsvd1[79];
+	u8 rsvd2[3];
+	u8 phy_port;
+	u32 rsvd3[13];
+} __packed;
+
+struct mgmt_controller_attrib {
+	struct mgmt_hba_attribs hba_attribs;
+	u32 rsvd0[10];
+} __packed;
+
 struct be_cmd_req_cntl_attribs {
 	struct be_cmd_req_hdr hdr;
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 6d7b3a4..8e91ae8 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -171,94 +171,6 @@
 #define RETRIEVE_FAT	0
 #define QUERY_FAT	1
 
-/* Flashrom related descriptors */
-#define MAX_FLASH_COMP			32
-#define IMAGE_TYPE_FIRMWARE		160
-#define IMAGE_TYPE_BOOTCODE		224
-#define IMAGE_TYPE_OPTIONROM		32
-
-#define NUM_FLASHDIR_ENTRIES		32
-
-#define OPTYPE_ISCSI_ACTIVE		0
-#define OPTYPE_REDBOOT			1
-#define OPTYPE_BIOS			2
-#define OPTYPE_PXE_BIOS			3
-#define OPTYPE_FCOE_BIOS		8
-#define OPTYPE_ISCSI_BACKUP		9
-#define OPTYPE_FCOE_FW_ACTIVE		10
-#define OPTYPE_FCOE_FW_BACKUP		11
-#define OPTYPE_NCSI_FW			13
-#define OPTYPE_REDBOOT_DIR		18
-#define OPTYPE_REDBOOT_CONFIG		19
-#define OPTYPE_SH_PHY_FW		21
-#define OPTYPE_FLASHISM_JUMPVECTOR	22
-#define OPTYPE_UFI_DIR			23
-#define OPTYPE_PHY_FW			99
-#define TN_8022				13
-
-#define FLASHROM_OPER_PHY_FLASH		9
-#define FLASHROM_OPER_PHY_SAVE		10
-#define FLASHROM_OPER_FLASH		1
-#define FLASHROM_OPER_SAVE		2
-#define FLASHROM_OPER_REPORT		4
-
-#define FLASH_IMAGE_MAX_SIZE_g2		(1310720) /* Max firmware image size */
-#define FLASH_BIOS_IMAGE_MAX_SIZE_g2	(262144)  /* Max OPTION ROM image sz */
-#define FLASH_REDBOOT_IMAGE_MAX_SIZE_g2	(262144)  /* Max Redboot image sz    */
-#define FLASH_IMAGE_MAX_SIZE_g3		(2097152) /* Max firmware image size */
-#define FLASH_BIOS_IMAGE_MAX_SIZE_g3	(524288)  /* Max OPTION ROM image sz */
-#define FLASH_REDBOOT_IMAGE_MAX_SIZE_g3	(1048576)  /* Max Redboot image sz    */
-#define FLASH_NCSI_IMAGE_MAX_SIZE_g3	(262144)
-#define FLASH_PHY_FW_IMAGE_MAX_SIZE_g3	262144
-
-#define FLASH_NCSI_MAGIC		(0x16032009)
-#define FLASH_NCSI_DISABLED		(0)
-#define FLASH_NCSI_ENABLED		(1)
-
-#define FLASH_NCSI_BITFILE_HDR_OFFSET	(0x600000)
-
-/* Offsets for components on Flash. */
-#define FLASH_iSCSI_PRIMARY_IMAGE_START_g2 (1048576)
-#define FLASH_iSCSI_BACKUP_IMAGE_START_g2  (2359296)
-#define FLASH_FCoE_PRIMARY_IMAGE_START_g2  (3670016)
-#define FLASH_FCoE_BACKUP_IMAGE_START_g2   (4980736)
-#define FLASH_iSCSI_BIOS_START_g2          (7340032)
-#define FLASH_PXE_BIOS_START_g2            (7864320)
-#define FLASH_FCoE_BIOS_START_g2           (524288)
-#define FLASH_REDBOOT_START_g2		  (0)
-
-#define FLASH_NCSI_START_g3		   (15990784)
-#define FLASH_iSCSI_PRIMARY_IMAGE_START_g3 (2097152)
-#define FLASH_iSCSI_BACKUP_IMAGE_START_g3  (4194304)
-#define FLASH_FCoE_PRIMARY_IMAGE_START_g3  (6291456)
-#define FLASH_FCoE_BACKUP_IMAGE_START_g3   (8388608)
-#define FLASH_iSCSI_BIOS_START_g3          (12582912)
-#define FLASH_PXE_BIOS_START_g3            (13107200)
-#define FLASH_FCoE_BIOS_START_g3           (13631488)
-#define FLASH_REDBOOT_START_g3             (262144)
-#define FLASH_PHY_FW_START_g3		   1310720
-
-#define IMAGE_NCSI			16
-#define IMAGE_OPTION_ROM_PXE		32
-#define IMAGE_OPTION_ROM_FCoE		33
-#define IMAGE_OPTION_ROM_ISCSI		34
-#define IMAGE_FLASHISM_JUMPVECTOR	48
-#define IMAGE_FLASH_ISM			49
-#define IMAGE_JUMP_VECTOR		50
-#define IMAGE_FIRMWARE_iSCSI		160
-#define IMAGE_FIRMWARE_COMP_iSCSI	161
-#define IMAGE_FIRMWARE_FCoE		162
-#define IMAGE_FIRMWARE_COMP_FCoE	163
-#define IMAGE_FIRMWARE_BACKUP_iSCSI	176
-#define IMAGE_FIRMWARE_BACKUP_COMP_iSCSI 177
-#define IMAGE_FIRMWARE_BACKUP_FCoE	178
-#define IMAGE_FIRMWARE_BACKUP_COMP_FCoE 179
-#define IMAGE_FIRMWARE_PHY		192
-#define IMAGE_REDBOOT_DIR		208
-#define IMAGE_REDBOOT_CONFIG		209
-#define IMAGE_UFI_DIR			210
-#define IMAGE_BOOT_CODE			224
-
 /************* Rx Packet Type Encoding **************/
 #define BE_UNICAST_PACKET		0
 #define BE_MULTICAST_PACKET		1
@@ -440,138 +352,3 @@ struct amap_eth_rx_compl_v1 {
 struct be_eth_rx_compl {
 	u32 dw[4];
 };
-
-struct mgmt_hba_attribs {
-	u8 flashrom_version_string[32];
-	u8 manufacturer_name[32];
-	u32 supported_modes;
-	u32 rsvd0[3];
-	u8 ncsi_ver_string[12];
-	u32 default_extended_timeout;
-	u8 controller_model_number[32];
-	u8 controller_description[64];
-	u8 controller_serial_number[32];
-	u8 ip_version_string[32];
-	u8 firmware_version_string[32];
-	u8 bios_version_string[32];
-	u8 redboot_version_string[32];
-	u8 driver_version_string[32];
-	u8 fw_on_flash_version_string[32];
-	u32 functionalities_supported;
-	u16 max_cdblength;
-	u8 asic_revision;
-	u8 generational_guid[16];
-	u8 hba_port_count;
-	u16 default_link_down_timeout;
-	u8 iscsi_ver_min_max;
-	u8 multifunction_device;
-	u8 cache_valid;
-	u8 hba_status;
-	u8 max_domains_supported;
-	u8 phy_port;
-	u32 firmware_post_status;
-	u32 hba_mtu[8];
-	u32 rsvd1[4];
-};
-
-struct mgmt_controller_attrib {
-	struct mgmt_hba_attribs hba_attribs;
-	u16 pci_vendor_id;
-	u16 pci_device_id;
-	u16 pci_sub_vendor_id;
-	u16 pci_sub_system_id;
-	u8 pci_bus_number;
-	u8 pci_device_number;
-	u8 pci_function_number;
-	u8 interface_type;
-	u64 unique_identifier;
-	u32 rsvd0[5];
-};
-
-struct controller_id {
-	u32 vendor;
-	u32 device;
-	u32 subvendor;
-	u32 subdevice;
-};
-
-struct flash_comp {
-	unsigned long offset;
-	int optype;
-	int size;
-	int img_type;
-};
-
-struct image_hdr {
-	u32 imageid;
-	u32 imageoffset;
-	u32 imagelength;
-	u32 image_checksum;
-	u8 image_version[32];
-};
-struct flash_file_hdr_g2 {
-	u8 sign[32];
-	u32 cksum;
-	u32 antidote;
-	struct controller_id cont_id;
-	u32 file_len;
-	u32 chunk_num;
-	u32 total_chunks;
-	u32 num_imgs;
-	u8 build[24];
-};
-
-struct flash_file_hdr_g3 {
-	u8 sign[52];
-	u8 ufi_version[4];
-	u32 file_len;
-	u32 cksum;
-	u32 antidote;
-	u32 num_imgs;
-	u8 build[24];
-	u8 asic_type_rev;
-	u8 rsvd[31];
-};
-
-struct flash_section_hdr {
-	u32 format_rev;
-	u32 cksum;
-	u32 antidote;
-	u32 num_images;
-	u8 id_string[128];
-	u32 rsvd[4];
-} __packed;
-
-struct flash_section_hdr_g2 {
-	u32 format_rev;
-	u32 cksum;
-	u32 antidote;
-	u32 build_num;
-	u8 id_string[128];
-	u32 rsvd[8];
-} __packed;
-
-struct flash_section_entry {
-	u32 type;
-	u32 offset;
-	u32 pad_size;
-	u32 image_size;
-	u32 cksum;
-	u32 entry_point;
-	u16 optype;
-	u16 rsvd0;
-	u32 rsvd1;
-	u8 ver_data[32];
-} __packed;
-
-struct flash_section_info {
-	u8 cookie[32];
-	struct flash_section_hdr fsec_hdr;
-	struct flash_section_entry fsec_entry[32];
-} __packed;
-
-struct flash_section_info_g2 {
-	u8 cookie[32];
-	struct flash_section_hdr_g2 fsec_hdr;
-	struct flash_section_entry fsec_entry[32];
-} __packed;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0b0482b..6c10fec 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3762,7 +3762,7 @@ static char flash_cookie[2][16] = {"*** SE FLAS", "H DIRECTORY *** "};
 
 static bool phy_flashing_required(struct be_adapter *adapter)
 {
-	return (adapter->phy.phy_type == TN_8022 &&
+	return (adapter->phy.phy_type == PHY_TYPE_TN_8022 &&
 		adapter->phy.interface_type == PHY_TYPE_BASET_10GB);
 }
 
-- 
2.2.0
