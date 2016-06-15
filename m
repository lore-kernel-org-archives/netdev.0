From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 16/17] sfc: Update MCDI protocol definitions
Date: Wed, 15 Jun 2016 17:51:48 +0100
Message-ID: <58f29467-c4f6-0de6-cf37-3b368394c477@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:30688 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932141AbcFOQwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:52:07 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 1327 ++++++++++++++++++++++++++++++++--
 1 file changed, 1279 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 4cc7721..c9a5b00 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -273,6 +273,9 @@
  * have already installed filters. See the comment at
  * MC_CMD_WORKAROUND_BUG26807. */
 #define MC_CMD_ERR_FILTERS_PRESENT 0x1014
+/* The clock whose frequency you've attempted to set set
+ * doesn't exist on this NIC */
+#define MC_CMD_ERR_NO_CLOCK 0x1015
 
 #define MC_CMD_ERR_CODE_OFST 0
 
@@ -292,9 +295,11 @@
 /* Point to the copycode entry point. */
 #define SIENA_MC_BOOTROM_COPYCODE_VEC (0x800 - 3 * 0x4)
 #define HUNT_MC_BOOTROM_COPYCODE_VEC (0x8000 - 3 * 0x4)
+#define MEDFORD_MC_BOOTROM_COPYCODE_VEC (0x10000 - 3 * 0x4)
 /* Points to the recovery mode entry point. */
 #define SIENA_MC_BOOTROM_NOFLASH_VEC (0x800 - 2 * 0x4)
 #define HUNT_MC_BOOTROM_NOFLASH_VEC (0x8000 - 2 * 0x4)
+#define MEDFORD_MC_BOOTROM_NOFLASH_VEC (0x10000 - 2 * 0x4)
 
 /* The command set exported by the boot ROM (MCDI v0) */
 #define MC_CMD_GET_VERSION_V0_SUPPORTED_FUNCS {		\
@@ -686,6 +691,12 @@
 #define          FCDI_EVENT_CODE_PTP_STATUS 0x9
 /* enum: Port id config to map MC-FC port idx */
 #define          FCDI_EVENT_CODE_PORT_CONFIG 0xa
+/* enum: Boot result or error code */
+#define          FCDI_EVENT_CODE_BOOT_RESULT 0xb
+#define       FCDI_EVENT_REBOOT_SRC_LBN 36
+#define       FCDI_EVENT_REBOOT_SRC_WIDTH 8
+#define          FCDI_EVENT_REBOOT_FC_FW 0x0 /* enum */
+#define          FCDI_EVENT_REBOOT_FC_BOOTLOADER 0x1 /* enum */
 #define       FCDI_EVENT_ASSERT_INSTR_ADDRESS_OFST 0
 #define       FCDI_EVENT_ASSERT_INSTR_ADDRESS_LBN 0
 #define       FCDI_EVENT_ASSERT_INSTR_ADDRESS_WIDTH 32
@@ -717,6 +728,11 @@
 #define       FCDI_EVENT_PORT_CONFIG_DATA_OFST 0
 #define       FCDI_EVENT_PORT_CONFIG_DATA_LBN 0
 #define       FCDI_EVENT_PORT_CONFIG_DATA_WIDTH 32
+#define       FCDI_EVENT_BOOT_RESULT_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_AOE/MC_CMD_AOE_OUT_INFO/FC_BOOT_RESULT */
+#define       FCDI_EVENT_BOOT_RESULT_LBN 0
+#define       FCDI_EVENT_BOOT_RESULT_WIDTH 32
 
 /* FCDI_EXTENDED_EVENT_PPS structuredef: Extended FCDI event to send PPS events
  * to the MC. Note that this structure | is overlayed over a normal FCDI event
@@ -1649,15 +1665,30 @@
 
 /* MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS msgresponse */
 #define    MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_LEN 16
-/* Uncorrected error on transmit timestamps in NIC clock format */
+/* Uncorrected error on PTP transmit timestamps in NIC clock format */
 #define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_TRANSMIT_OFST 0
-/* Uncorrected error on receive timestamps in NIC clock format */
+/* Uncorrected error on PTP receive timestamps in NIC clock format */
 #define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_RECEIVE_OFST 4
 /* Uncorrected error on PPS output in NIC clock format */
 #define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_PPS_OUT_OFST 8
 /* Uncorrected error on PPS input in NIC clock format */
 #define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_PPS_IN_OFST 12
 
+/* MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2 msgresponse */
+#define    MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_LEN 24
+/* Uncorrected error on PTP transmit timestamps in NIC clock format */
+#define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_PTP_TX_OFST 0
+/* Uncorrected error on PTP receive timestamps in NIC clock format */
+#define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_PTP_RX_OFST 4
+/* Uncorrected error on PPS output in NIC clock format */
+#define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_PPS_OUT_OFST 8
+/* Uncorrected error on PPS input in NIC clock format */
+#define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_PPS_IN_OFST 12
+/* Uncorrected error on non-PTP transmit timestamps in NIC clock format */
+#define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_GENERAL_TX_OFST 16
+/* Uncorrected error on non-PTP receive timestamps in NIC clock format */
+#define       MC_CMD_PTP_OUT_GET_TIMESTAMP_CORRECTIONS_V2_GENERAL_RX_OFST 20
+
 /* MC_CMD_PTP_OUT_MANFTEST_PPS msgresponse */
 #define    MC_CMD_PTP_OUT_MANFTEST_PPS_LEN 4
 /* Results of testing */
@@ -2158,8 +2189,12 @@
 
 /* MC_CMD_DRV_ATTACH_IN msgrequest */
 #define    MC_CMD_DRV_ATTACH_IN_LEN 12
-/* new state (0=detached, 1=attached) to set if UPDATE=1 */
+/* new state to set if UPDATE=1 */
 #define       MC_CMD_DRV_ATTACH_IN_NEW_STATE_OFST 0
+#define        MC_CMD_DRV_ATTACH_LBN 0
+#define        MC_CMD_DRV_ATTACH_WIDTH 1
+#define        MC_CMD_DRV_PREBOOT_LBN 1
+#define        MC_CMD_DRV_PREBOOT_WIDTH 1
 /* 1 to set new state, or 0 to just report the existing state */
 #define       MC_CMD_DRV_ATTACH_IN_UPDATE_OFST 4
 /* preferred datapath firmware (for Huntington; ignored for Siena) */
@@ -2181,12 +2216,12 @@
 
 /* MC_CMD_DRV_ATTACH_OUT msgresponse */
 #define    MC_CMD_DRV_ATTACH_OUT_LEN 4
-/* previous or existing state (0=detached, 1=attached) */
+/* previous or existing state, see the bitmask at NEW_STATE */
 #define       MC_CMD_DRV_ATTACH_OUT_OLD_STATE_OFST 0
 
 /* MC_CMD_DRV_ATTACH_EXT_OUT msgresponse */
 #define    MC_CMD_DRV_ATTACH_EXT_OUT_LEN 8
-/* previous or existing state (0=detached, 1=attached) */
+/* previous or existing state, see the bitmask at NEW_STATE */
 #define       MC_CMD_DRV_ATTACH_EXT_OUT_OLD_STATE_OFST 0
 /* Flags associated with this function */
 #define       MC_CMD_DRV_ATTACH_EXT_OUT_FUNC_FLAGS_OFST 4
@@ -2198,6 +2233,10 @@
 #define          MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL 0x1
 /* enum: The function can perform privileged operations */
 #define          MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED 0x2
+/* enum: The function does not have an active port associated with it. The port
+ * refers to the Sorrento external FPGA port.
+ */
+#define          MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_NO_ACTIVE_PORT 0x3
 
 
 /***********************************/
@@ -2892,7 +2931,7 @@
  */
 #define MC_CMD_SET_MAC 0x2c
 
-#define MC_CMD_0x2c_PRIVILEGE_CTG SRIOV_CTG_LINK
+#define MC_CMD_0x2c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_SET_MAC_IN msgrequest */
 #define    MC_CMD_SET_MAC_IN_LEN 28
@@ -2927,9 +2966,66 @@
 #define        MC_CMD_SET_MAC_IN_FLAG_INCLUDE_FCS_LBN 0
 #define        MC_CMD_SET_MAC_IN_FLAG_INCLUDE_FCS_WIDTH 1
 
+/* MC_CMD_SET_MAC_EXT_IN msgrequest */
+#define    MC_CMD_SET_MAC_EXT_IN_LEN 32
+/* The MTU is the MTU programmed directly into the XMAC/GMAC (inclusive of
+ * EtherII, VLAN, bug16011 padding).
+ */
+#define       MC_CMD_SET_MAC_EXT_IN_MTU_OFST 0
+#define       MC_CMD_SET_MAC_EXT_IN_DRAIN_OFST 4
+#define       MC_CMD_SET_MAC_EXT_IN_ADDR_OFST 8
+#define       MC_CMD_SET_MAC_EXT_IN_ADDR_LEN 8
+#define       MC_CMD_SET_MAC_EXT_IN_ADDR_LO_OFST 8
+#define       MC_CMD_SET_MAC_EXT_IN_ADDR_HI_OFST 12
+#define       MC_CMD_SET_MAC_EXT_IN_REJECT_OFST 16
+#define        MC_CMD_SET_MAC_EXT_IN_REJECT_UNCST_LBN 0
+#define        MC_CMD_SET_MAC_EXT_IN_REJECT_UNCST_WIDTH 1
+#define        MC_CMD_SET_MAC_EXT_IN_REJECT_BRDCST_LBN 1
+#define        MC_CMD_SET_MAC_EXT_IN_REJECT_BRDCST_WIDTH 1
+#define       MC_CMD_SET_MAC_EXT_IN_FCNTL_OFST 20
+/* enum: Flow control is off. */
+/*               MC_CMD_FCNTL_OFF 0x0 */
+/* enum: Respond to flow control. */
+/*               MC_CMD_FCNTL_RESPOND 0x1 */
+/* enum: Respond to and Issue flow control. */
+/*               MC_CMD_FCNTL_BIDIR 0x2 */
+/* enum: Auto neg flow control. */
+/*               MC_CMD_FCNTL_AUTO 0x3 */
+/* enum: Priority flow control (eftest builds only). */
+/*               MC_CMD_FCNTL_QBB 0x4 */
+/* enum: Issue flow control. */
+/*               MC_CMD_FCNTL_GENERATE 0x5 */
+#define       MC_CMD_SET_MAC_EXT_IN_FLAGS_OFST 24
+#define        MC_CMD_SET_MAC_EXT_IN_FLAG_INCLUDE_FCS_LBN 0
+#define        MC_CMD_SET_MAC_EXT_IN_FLAG_INCLUDE_FCS_WIDTH 1
+/* Select which parameters to configure. A parameter will only be modified if
+ * the corresponding control flag is set. If SET_MAC_ENHANCED is not set in
+ * capabilities then this field is ignored (and all flags are assumed to be
+ * set).
+ */
+#define       MC_CMD_SET_MAC_EXT_IN_CONTROL_OFST 28
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_MTU_LBN 0
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_MTU_WIDTH 1
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_DRAIN_LBN 1
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_DRAIN_WIDTH 1
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_REJECT_LBN 2
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_REJECT_WIDTH 1
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_FCNTL_LBN 3
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_FCNTL_WIDTH 1
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_FCS_LBN 4
+#define        MC_CMD_SET_MAC_EXT_IN_CFG_FCS_WIDTH 1
+
 /* MC_CMD_SET_MAC_OUT msgresponse */
 #define    MC_CMD_SET_MAC_OUT_LEN 0
 
+/* MC_CMD_SET_MAC_V2_OUT msgresponse */
+#define    MC_CMD_SET_MAC_V2_OUT_LEN 4
+/* MTU as configured after processing the request. See comment at
+ * MC_CMD_SET_MAC_IN/MTU. To query MTU without doing any changes, set CONTROL
+ * to 0.
+ */
+#define       MC_CMD_SET_MAC_V2_OUT_MTU_OFST 0
+
 
 /***********************************/
 /* MC_CMD_PHY_STATS
@@ -3521,6 +3617,26 @@
 #define       MC_CMD_NVRAM_INFO_OUT_PHYSDEV_OFST 16
 #define       MC_CMD_NVRAM_INFO_OUT_PHYSADDR_OFST 20
 
+/* MC_CMD_NVRAM_INFO_V2_OUT msgresponse */
+#define    MC_CMD_NVRAM_INFO_V2_OUT_LEN 28
+#define       MC_CMD_NVRAM_INFO_V2_OUT_TYPE_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_NVRAM_TYPES/MC_CMD_NVRAM_TYPES_OUT/TYPES */
+#define       MC_CMD_NVRAM_INFO_V2_OUT_SIZE_OFST 4
+#define       MC_CMD_NVRAM_INFO_V2_OUT_ERASESIZE_OFST 8
+#define       MC_CMD_NVRAM_INFO_V2_OUT_FLAGS_OFST 12
+#define        MC_CMD_NVRAM_INFO_V2_OUT_PROTECTED_LBN 0
+#define        MC_CMD_NVRAM_INFO_V2_OUT_PROTECTED_WIDTH 1
+#define        MC_CMD_NVRAM_INFO_V2_OUT_TLV_LBN 1
+#define        MC_CMD_NVRAM_INFO_V2_OUT_TLV_WIDTH 1
+#define        MC_CMD_NVRAM_INFO_V2_OUT_A_B_LBN 7
+#define        MC_CMD_NVRAM_INFO_V2_OUT_A_B_WIDTH 1
+#define       MC_CMD_NVRAM_INFO_V2_OUT_PHYSDEV_OFST 16
+#define       MC_CMD_NVRAM_INFO_V2_OUT_PHYSADDR_OFST 20
+/* Writes must be multiples of this size. Added to support the MUM on Sorrento.
+ */
+#define       MC_CMD_NVRAM_INFO_V2_OUT_WRITESIZE_OFST 24
+
 
 /***********************************/
 /* MC_CMD_NVRAM_UPDATE_START
@@ -3561,6 +3677,37 @@
 /* amount to read in bytes */
 #define       MC_CMD_NVRAM_READ_IN_LENGTH_OFST 8
 
+/* MC_CMD_NVRAM_READ_IN_V2 msgrequest */
+#define    MC_CMD_NVRAM_READ_IN_V2_LEN 16
+#define       MC_CMD_NVRAM_READ_IN_V2_TYPE_OFST 0
+/*            Enum values, see field(s): */
+/*               MC_CMD_NVRAM_TYPES/MC_CMD_NVRAM_TYPES_OUT/TYPES */
+#define       MC_CMD_NVRAM_READ_IN_V2_OFFSET_OFST 4
+/* amount to read in bytes */
+#define       MC_CMD_NVRAM_READ_IN_V2_LENGTH_OFST 8
+/* Optional control info. If a partition is stored with an A/B versioning
+ * scheme (i.e. in more than one physical partition in NVRAM) the host can set
+ * this to control which underlying physical partition is used to read data
+ * from. This allows it to perform a read-modify-write-verify with the write
+ * lock continuously held by calling NVRAM_UPDATE_START, reading the old
+ * contents using MODE=TARGET_CURRENT, overwriting the old partition and then
+ * verifying by reading with MODE=TARGET_BACKUP.
+ */
+#define       MC_CMD_NVRAM_READ_IN_V2_MODE_OFST 12
+/* enum: Same as omitting MODE: caller sees data in current partition unless it
+ * holds the write lock in which case it sees data in the partition it is
+ * updating.
+ */
+#define          MC_CMD_NVRAM_READ_IN_V2_DEFAULT 0x0
+/* enum: Read from the current partition of an A/B pair, even if holding the
+ * write lock.
+ */
+#define          MC_CMD_NVRAM_READ_IN_V2_TARGET_CURRENT 0x1
+/* enum: Read from the non-current (i.e. to be updated) partition of an A/B
+ * pair
+ */
+#define          MC_CMD_NVRAM_READ_IN_V2_TARGET_BACKUP 0x2
+
 /* MC_CMD_NVRAM_READ_OUT msgresponse */
 #define    MC_CMD_NVRAM_READ_OUT_LENMIN 1
 #define    MC_CMD_NVRAM_READ_OUT_LENMAX 252
@@ -3895,6 +4042,8 @@
 #define          MC_CMD_SENSOR_CCOM_AVREG_1V8_SUPPLY  0x39
 /* enum: CCOM AVREG 1v8 supply (external ADC): mV */
 #define          MC_CMD_SENSOR_CCOM_AVREG_1V8_SUPPLY_EXTADC  0x3a
+/* enum: CCOM RTS temperature: degC */
+#define          MC_CMD_SENSOR_CONTROLLER_RTS  0x3b
 /* enum: Not a sensor: reserved for the next page flag */
 #define          MC_CMD_SENSOR_PAGE1_NEXT  0x3f
 /* enum: controller internal temperature sensor voltage on master core
@@ -3931,6 +4080,12 @@
 #define          MC_CMD_SENSOR_PHY0_VCC  0x4c
 /* enum: Voltage supplied to the QSFP #1 from their power supply: mV */
 #define          MC_CMD_SENSOR_PHY1_VCC  0x4d
+/* enum: Controller die temperature (TDIODE): degC */
+#define          MC_CMD_SENSOR_CONTROLLER_TDIODE_TEMP  0x4e
+/* enum: Board temperature (front): degC */
+#define          MC_CMD_SENSOR_BOARD_FRONT_TEMP  0x4f
+/* enum: Board temperature (back): degC */
+#define          MC_CMD_SENSOR_BOARD_BACK_TEMP  0x50
 /* MC_CMD_SENSOR_INFO_ENTRY_TYPEDEF */
 #define       MC_CMD_SENSOR_ENTRY_OFST 4
 #define       MC_CMD_SENSOR_ENTRY_LEN 8
@@ -4007,7 +4162,7 @@
 
 /* MC_CMD_READ_SENSORS_EXT_IN msgrequest */
 #define    MC_CMD_READ_SENSORS_EXT_IN_LEN 12
-/* DMA address of host buffer for sensor readings */
+/* DMA address of host buffer for sensor readings (must be 4Kbyte aligned). */
 #define       MC_CMD_READ_SENSORS_EXT_IN_DMA_ADDR_OFST 0
 #define       MC_CMD_READ_SENSORS_EXT_IN_DMA_ADDR_LEN 8
 #define       MC_CMD_READ_SENSORS_EXT_IN_DMA_ADDR_LO_OFST 0
@@ -4608,6 +4763,10 @@
  * operations
  */
 #define          MC_CMD_MUM_OP_QSFP 0xc
+/* enum: Request discrete and SODIMM DDR info (type, size, speed grade, voltage
+ * level) from MUM
+ */
+#define          MC_CMD_MUM_OP_READ_DDR_INFO 0xd
 
 /* MC_CMD_MUM_IN_NULL msgrequest */
 #define    MC_CMD_MUM_IN_NULL_LEN 4
@@ -4793,6 +4952,10 @@
 #define       MC_CMD_MUM_IN_PROGRAM_CLOCKS_FLAGS_OFST 8
 #define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_OVERCLOCK_110_LBN 0
 #define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_OVERCLOCK_110_WIDTH 1
+#define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_CLOCK_NIC_FROM_FPGA_LBN 1
+#define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_CLOCK_NIC_FROM_FPGA_WIDTH 1
+#define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_CLOCK_REF_FROM_XO_LBN 2
+#define        MC_CMD_MUM_IN_PROGRAM_CLOCKS_CLOCK_REF_FROM_XO_WIDTH 1
 
 /* MC_CMD_MUM_IN_FPGA_LOAD msgrequest */
 #define    MC_CMD_MUM_IN_FPGA_LOAD_LEN 8
@@ -4862,6 +5025,11 @@
 #define       MC_CMD_MUM_IN_QSFP_POLL_BIST_HDR_OFST 4
 #define       MC_CMD_MUM_IN_QSFP_POLL_BIST_IDX_OFST 8
 
+/* MC_CMD_MUM_IN_READ_DDR_INFO msgrequest */
+#define    MC_CMD_MUM_IN_READ_DDR_INFO_LEN 4
+/* MUM cmd header */
+/*            MC_CMD_MUM_IN_CMD_OFST 0 */
+
 /* MC_CMD_MUM_OUT msgresponse */
 #define    MC_CMD_MUM_OUT_LEN 0
 
@@ -5004,6 +5172,69 @@
 #define    MC_CMD_MUM_OUT_QSFP_POLL_BIST_LEN 4
 #define       MC_CMD_MUM_OUT_QSFP_POLL_BIST_TEST_OFST 0
 
+/* MC_CMD_MUM_OUT_READ_DDR_INFO msgresponse */
+#define    MC_CMD_MUM_OUT_READ_DDR_INFO_LENMIN 24
+#define    MC_CMD_MUM_OUT_READ_DDR_INFO_LENMAX 248
+#define    MC_CMD_MUM_OUT_READ_DDR_INFO_LEN(num) (8+8*(num))
+/* Discrete (soldered) DDR resistor strap info */
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_DISCRETE_DDR_INFO_OFST 0
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_VRATIO_LBN 0
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_VRATIO_WIDTH 16
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_RESERVED1_LBN 16
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_RESERVED1_WIDTH 16
+/* Number of SODIMM info records */
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_NUM_RECORDS_OFST 4
+/* Array of SODIMM info records */
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_SODIMM_INFO_RECORD_OFST 8
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_SODIMM_INFO_RECORD_LEN 8
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_SODIMM_INFO_RECORD_LO_OFST 8
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_SODIMM_INFO_RECORD_HI_OFST 12
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_SODIMM_INFO_RECORD_MINNUM 2
+#define       MC_CMD_MUM_OUT_READ_DDR_INFO_SODIMM_INFO_RECORD_MAXNUM 30
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_BANK_ID_LBN 0
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_BANK_ID_WIDTH 8
+/* enum: SODIMM bank 1 (Top SODIMM for Sorrento) */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_BANK1 0x0
+/* enum: SODIMM bank 2 (Bottom SODDIMM for Sorrento) */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_BANK2 0x1
+/* enum: Total number of SODIMM banks */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_NUM_BANKS 0x2
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_TYPE_LBN 8
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_TYPE_WIDTH 8
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_RANK_LBN 16
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_RANK_WIDTH 4
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_VOLTAGE_LBN 20
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_VOLTAGE_WIDTH 4
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_NOT_POWERED 0x0 /* enum */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_1V25 0x1 /* enum */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_1V35 0x2 /* enum */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_1V5 0x3 /* enum */
+/* enum: Values 5-15 are reserved for future usage */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_1V8 0x4
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_SIZE_LBN 24
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_SIZE_WIDTH 8
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_SPEED_LBN 32
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_SPEED_WIDTH 16
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_STATE_LBN 48
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_STATE_WIDTH 4
+/* enum: No module present */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_ABSENT 0x0
+/* enum: Module present supported and powered on */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_PRESENT_POWERED 0x1
+/* enum: Module present but bad type */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_PRESENT_BAD_TYPE 0x2
+/* enum: Module present but incompatible voltage */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_PRESENT_BAD_VOLTAGE 0x3
+/* enum: Module present but unknown SPD */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_PRESENT_BAD_SPD 0x4
+/* enum: Module present but slot cannot support it */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_PRESENT_BAD_SLOT 0x5
+/* enum: Modules may or may not be present, but cannot establish contact by I2C
+ */
+#define          MC_CMD_MUM_OUT_READ_DDR_INFO_NOT_REACHABLE 0x6
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_RESERVED2_LBN 52
+#define        MC_CMD_MUM_OUT_READ_DDR_INFO_RESERVED2_WIDTH 12
+
 /* MC_CMD_RESOURCE_SPECIFIER enum */
 /* enum: Any */
 #define          MC_CMD_RESOURCE_INSTANCE_ANY 0xffffffff
@@ -5076,6 +5307,8 @@
 #define          NVRAM_PARTITION_TYPE_DYNAMIC_CONFIG       0x500
 /* enum: Expansion ROM configuration data for port 0 */
 #define          NVRAM_PARTITION_TYPE_EXPROM_CONFIG_PORT0  0x600
+/* enum: Synonym for EXPROM_CONFIG_PORT0 as used in pmap files */
+#define          NVRAM_PARTITION_TYPE_EXPROM_CONFIG        0x600
 /* enum: Expansion ROM configuration data for port 1 */
 #define          NVRAM_PARTITION_TYPE_EXPROM_CONFIG_PORT1  0x601
 /* enum: Expansion ROM configuration data for port 2 */
@@ -5084,6 +5317,8 @@
 #define          NVRAM_PARTITION_TYPE_EXPROM_CONFIG_PORT3  0x603
 /* enum: Non-volatile log output partition */
 #define          NVRAM_PARTITION_TYPE_LOG                  0x700
+/* enum: Non-volatile log output of second core on dual-core device */
+#define          NVRAM_PARTITION_TYPE_LOG_SLAVE            0x701
 /* enum: Device state dump output partition */
 #define          NVRAM_PARTITION_TYPE_DUMP                 0x800
 /* enum: Application license key storage partition */
@@ -5116,6 +5351,20 @@
 #define          NVRAM_PARTITION_TYPE_MUM_USER_ROM         0xc05
 /* enum: MUM fuses and lockbits partition. */
 #define          NVRAM_PARTITION_TYPE_MUM_FUSELOCK         0xc06
+/* enum: UEFI expansion ROM if separate from PXE */
+#define          NVRAM_PARTITION_TYPE_EXPANSION_UEFI       0xd00
+/* enum: Spare partition 0 */
+#define          NVRAM_PARTITION_TYPE_SPARE_0              0x1000
+/* enum: Spare partition 1 */
+#define          NVRAM_PARTITION_TYPE_SPARE_1              0x1100
+/* enum: Spare partition 2 */
+#define          NVRAM_PARTITION_TYPE_SPARE_2              0x1200
+/* enum: Spare partition 3 */
+#define          NVRAM_PARTITION_TYPE_SPARE_3              0x1300
+/* enum: Spare partition 4 */
+#define          NVRAM_PARTITION_TYPE_SPARE_4              0x1400
+/* enum: Spare partition 5 */
+#define          NVRAM_PARTITION_TYPE_SPARE_5              0x1500
 /* enum: Start of reserved value range (firmware may use for any purpose) */
 #define          NVRAM_PARTITION_TYPE_RESERVED_VALUES_MIN  0xff00
 /* enum: End of reserved value range (firmware may use for any purpose) */
@@ -5149,6 +5398,90 @@
 #define       LICENSED_APP_ID_ID_LBN 0
 #define       LICENSED_APP_ID_ID_WIDTH 32
 
+/* LICENSED_FEATURES structuredef */
+#define    LICENSED_FEATURES_LEN 8
+/* Bitmask of licensed firmware features */
+#define       LICENSED_FEATURES_MASK_OFST 0
+#define       LICENSED_FEATURES_MASK_LEN 8
+#define       LICENSED_FEATURES_MASK_LO_OFST 0
+#define       LICENSED_FEATURES_MASK_HI_OFST 4
+#define        LICENSED_FEATURES_RX_CUT_THROUGH_LBN 0
+#define        LICENSED_FEATURES_RX_CUT_THROUGH_WIDTH 1
+#define        LICENSED_FEATURES_PIO_LBN 1
+#define        LICENSED_FEATURES_PIO_WIDTH 1
+#define        LICENSED_FEATURES_EVQ_TIMER_LBN 2
+#define        LICENSED_FEATURES_EVQ_TIMER_WIDTH 1
+#define        LICENSED_FEATURES_CLOCK_LBN 3
+#define        LICENSED_FEATURES_CLOCK_WIDTH 1
+#define        LICENSED_FEATURES_RX_TIMESTAMPS_LBN 4
+#define        LICENSED_FEATURES_RX_TIMESTAMPS_WIDTH 1
+#define        LICENSED_FEATURES_TX_TIMESTAMPS_LBN 5
+#define        LICENSED_FEATURES_TX_TIMESTAMPS_WIDTH 1
+#define        LICENSED_FEATURES_RX_SNIFF_LBN 6
+#define        LICENSED_FEATURES_RX_SNIFF_WIDTH 1
+#define        LICENSED_FEATURES_TX_SNIFF_LBN 7
+#define        LICENSED_FEATURES_TX_SNIFF_WIDTH 1
+#define        LICENSED_FEATURES_PROXY_FILTER_OPS_LBN 8
+#define        LICENSED_FEATURES_PROXY_FILTER_OPS_WIDTH 1
+#define        LICENSED_FEATURES_EVENT_CUT_THROUGH_LBN 9
+#define        LICENSED_FEATURES_EVENT_CUT_THROUGH_WIDTH 1
+#define       LICENSED_FEATURES_MASK_LBN 0
+#define       LICENSED_FEATURES_MASK_WIDTH 64
+
+/* LICENSED_V3_APPS structuredef */
+#define    LICENSED_V3_APPS_LEN 8
+/* Bitmask of licensed applications */
+#define       LICENSED_V3_APPS_MASK_OFST 0
+#define       LICENSED_V3_APPS_MASK_LEN 8
+#define       LICENSED_V3_APPS_MASK_LO_OFST 0
+#define       LICENSED_V3_APPS_MASK_HI_OFST 4
+#define        LICENSED_V3_APPS_ONLOAD_LBN 0
+#define        LICENSED_V3_APPS_ONLOAD_WIDTH 1
+#define        LICENSED_V3_APPS_PTP_LBN 1
+#define        LICENSED_V3_APPS_PTP_WIDTH 1
+#define        LICENSED_V3_APPS_SOLARCAPTURE_PRO_LBN 2
+#define        LICENSED_V3_APPS_SOLARCAPTURE_PRO_WIDTH 1
+#define        LICENSED_V3_APPS_SOLARSECURE_LBN 3
+#define        LICENSED_V3_APPS_SOLARSECURE_WIDTH 1
+#define        LICENSED_V3_APPS_PERF_MONITOR_LBN 4
+#define        LICENSED_V3_APPS_PERF_MONITOR_WIDTH 1
+#define        LICENSED_V3_APPS_SOLARCAPTURE_LIVE_LBN 5
+#define        LICENSED_V3_APPS_SOLARCAPTURE_LIVE_WIDTH 1
+#define        LICENSED_V3_APPS_CAPTURE_SOLARSYSTEM_LBN 6
+#define        LICENSED_V3_APPS_CAPTURE_SOLARSYSTEM_WIDTH 1
+#define        LICENSED_V3_APPS_NETWORK_ACCESS_CONTROL_LBN 7
+#define        LICENSED_V3_APPS_NETWORK_ACCESS_CONTROL_WIDTH 1
+#define       LICENSED_V3_APPS_MASK_LBN 0
+#define       LICENSED_V3_APPS_MASK_WIDTH 64
+
+/* LICENSED_V3_FEATURES structuredef */
+#define    LICENSED_V3_FEATURES_LEN 8
+/* Bitmask of licensed firmware features */
+#define       LICENSED_V3_FEATURES_MASK_OFST 0
+#define       LICENSED_V3_FEATURES_MASK_LEN 8
+#define       LICENSED_V3_FEATURES_MASK_LO_OFST 0
+#define       LICENSED_V3_FEATURES_MASK_HI_OFST 4
+#define        LICENSED_V3_FEATURES_RX_CUT_THROUGH_LBN 0
+#define        LICENSED_V3_FEATURES_RX_CUT_THROUGH_WIDTH 1
+#define        LICENSED_V3_FEATURES_PIO_LBN 1
+#define        LICENSED_V3_FEATURES_PIO_WIDTH 1
+#define        LICENSED_V3_FEATURES_EVQ_TIMER_LBN 2
+#define        LICENSED_V3_FEATURES_EVQ_TIMER_WIDTH 1
+#define        LICENSED_V3_FEATURES_CLOCK_LBN 3
+#define        LICENSED_V3_FEATURES_CLOCK_WIDTH 1
+#define        LICENSED_V3_FEATURES_RX_TIMESTAMPS_LBN 4
+#define        LICENSED_V3_FEATURES_RX_TIMESTAMPS_WIDTH 1
+#define        LICENSED_V3_FEATURES_TX_TIMESTAMPS_LBN 5
+#define        LICENSED_V3_FEATURES_TX_TIMESTAMPS_WIDTH 1
+#define        LICENSED_V3_FEATURES_RX_SNIFF_LBN 6
+#define        LICENSED_V3_FEATURES_RX_SNIFF_WIDTH 1
+#define        LICENSED_V3_FEATURES_TX_SNIFF_LBN 7
+#define        LICENSED_V3_FEATURES_TX_SNIFF_WIDTH 1
+#define        LICENSED_V3_FEATURES_PROXY_FILTER_OPS_LBN 8
+#define        LICENSED_V3_FEATURES_PROXY_FILTER_OPS_WIDTH 1
+#define       LICENSED_V3_FEATURES_MASK_LBN 0
+#define       LICENSED_V3_FEATURES_MASK_WIDTH 64
+
 /* TX_TIMESTAMP_EVENT structuredef */
 #define    TX_TIMESTAMP_EVENT_LEN 6
 /* lower 16 bits of timestamp data */
@@ -5258,6 +5591,8 @@
 #define        MC_CMD_INIT_EVQ_IN_FLAG_RX_MERGE_WIDTH 1
 #define        MC_CMD_INIT_EVQ_IN_FLAG_TX_MERGE_LBN 5
 #define        MC_CMD_INIT_EVQ_IN_FLAG_TX_MERGE_WIDTH 1
+#define        MC_CMD_INIT_EVQ_IN_FLAG_USE_TIMER_LBN 6
+#define        MC_CMD_INIT_EVQ_IN_FLAG_USE_TIMER_WIDTH 1
 #define       MC_CMD_INIT_EVQ_IN_TMR_MODE_OFST 20
 /* enum: Disabled */
 #define          MC_CMD_INIT_EVQ_IN_TMR_MODE_DIS 0x0
@@ -5362,6 +5697,8 @@
 #define        MC_CMD_INIT_RXQ_IN_FLAG_PREFIX_WIDTH 1
 #define        MC_CMD_INIT_RXQ_IN_FLAG_DISABLE_SCATTER_LBN 9
 #define        MC_CMD_INIT_RXQ_IN_FLAG_DISABLE_SCATTER_WIDTH 1
+#define        MC_CMD_INIT_RXQ_IN_FLAG_FORCE_EV_MERGING_LBN 10
+#define        MC_CMD_INIT_RXQ_IN_FLAG_FORCE_EV_MERGING_WIDTH 1
 /* Owner ID to use if in buffer mode (zero if physical) */
 #define       MC_CMD_INIT_RXQ_IN_OWNER_ID_OFST 20
 /* The port ID associated with the v-adaptor which should contain this DMAQ. */
@@ -5422,6 +5759,8 @@
 #define          MC_CMD_INIT_RXQ_EXT_IN_PS_BUFF_64K  0x4 /* enum */
 #define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_WANT_OUTER_CLASSES_LBN 18
 #define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_WANT_OUTER_CLASSES_WIDTH 1
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_FORCE_EV_MERGING_LBN 19
+#define        MC_CMD_INIT_RXQ_EXT_IN_FLAG_FORCE_EV_MERGING_WIDTH 1
 /* Owner ID to use if in buffer mode (zero if physical) */
 #define       MC_CMD_INIT_RXQ_EXT_IN_OWNER_ID_OFST 20
 /* The port ID associated with the v-adaptor which should contain this DMAQ. */
@@ -5535,6 +5874,8 @@
 #define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_IP_CSUM_EN_WIDTH 1
 #define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_TCP_CSUM_EN_LBN 11
 #define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_INNER_TCP_CSUM_EN_WIDTH 1
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TSOV2_EN_LBN 12
+#define        MC_CMD_INIT_TXQ_EXT_IN_FLAG_TSOV2_EN_WIDTH 1
 /* Owner ID to use if in buffer mode (zero if physical) */
 #define       MC_CMD_INIT_TXQ_EXT_IN_OWNER_ID_OFST 20
 /* The port ID associated with the v-adaptor which should contain this DMAQ. */
@@ -5747,6 +6088,46 @@
 #define       MC_CMD_PROXY_CONFIGURE_IN_ALLOWED_MCDI_MASK_OFST 44
 #define       MC_CMD_PROXY_CONFIGURE_IN_ALLOWED_MCDI_MASK_LEN 64
 
+/* MC_CMD_PROXY_CONFIGURE_EXT_IN msgrequest */
+#define    MC_CMD_PROXY_CONFIGURE_EXT_IN_LEN 112
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_FLAGS_OFST 0
+#define        MC_CMD_PROXY_CONFIGURE_EXT_IN_ENABLE_LBN 0
+#define        MC_CMD_PROXY_CONFIGURE_EXT_IN_ENABLE_WIDTH 1
+/* Host provides a contiguous memory buffer that contains at least NUM_BLOCKS
+ * of blocks, each of the size REQUEST_BLOCK_SIZE.
+ */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_STATUS_BUFF_ADDR_OFST 4
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_STATUS_BUFF_ADDR_LEN 8
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_STATUS_BUFF_ADDR_LO_OFST 4
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_STATUS_BUFF_ADDR_HI_OFST 8
+/* Must be a power of 2 */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_STATUS_BLOCK_SIZE_OFST 12
+/* Host provides a contiguous memory buffer that contains at least NUM_BLOCKS
+ * of blocks, each of the size REPLY_BLOCK_SIZE.
+ */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REQUEST_BUFF_ADDR_OFST 16
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REQUEST_BUFF_ADDR_LEN 8
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REQUEST_BUFF_ADDR_LO_OFST 16
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REQUEST_BUFF_ADDR_HI_OFST 20
+/* Must be a power of 2 */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REQUEST_BLOCK_SIZE_OFST 24
+/* Host provides a contiguous memory buffer that contains at least NUM_BLOCKS
+ * of blocks, each of the size STATUS_BLOCK_SIZE. This buffer is only needed if
+ * host intends to complete proxied operations by using MC_CMD_PROXY_CMD.
+ */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REPLY_BUFF_ADDR_OFST 28
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REPLY_BUFF_ADDR_LEN 8
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REPLY_BUFF_ADDR_LO_OFST 28
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REPLY_BUFF_ADDR_HI_OFST 32
+/* Must be a power of 2, or zero if this buffer is not provided */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_REPLY_BLOCK_SIZE_OFST 36
+/* Applies to all three buffers */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_NUM_BLOCKS_OFST 40
+/* A bit mask defining which MCDI operations may be proxied */
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_ALLOWED_MCDI_MASK_OFST 44
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_ALLOWED_MCDI_MASK_LEN 64
+#define       MC_CMD_PROXY_CONFIGURE_EXT_IN_RESERVED_OFST 108
+
 /* MC_CMD_PROXY_CONFIGURE_OUT msgresponse */
 #define    MC_CMD_PROXY_CONFIGURE_OUT_LEN 0
 
@@ -6323,6 +6704,15 @@
  * client
  */
 #define          MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_RESTRICTIONS  0x2
+/* enum: read properties relating to security rules (Medford-only; for use by
+ * SolarSecure apps, not directly by drivers. See SF-114946-SW.)
+ */
+#define          MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_SECURITY_RULE_INFO  0x3
+/* enum: read the list of supported RX filter matches for VXLAN/NVGRE
+ * encapsulated frames, which follow a different match sequence to normal
+ * frames (Medford only)
+ */
+#define          MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_SUPPORTED_ENCAP_RX_MATCHES  0x4
 
 /* MC_CMD_GET_PARSER_DISP_INFO_OUT msgresponse */
 #define    MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMIN 8
@@ -6356,7 +6746,10 @@
 
 /***********************************/
 /* MC_CMD_PARSER_DISP_RW
- * Direct read/write of parser-dispatcher state (DICPUs and LUE) for debugging
+ * Direct read/write of parser-dispatcher state (DICPUs and LUE) for debugging.
+ * Please note that this interface is only of use to debug tools which have
+ * knowledge of firmware and hardware data structures; nothing here is intended
+ * for use by normal driver code.
  */
 #define MC_CMD_PARSER_DISP_RW 0xe5
 
@@ -6374,6 +6767,12 @@
 #define          MC_CMD_PARSER_DISP_RW_IN_LUE  0x2
 /* enum: Lookup engine (with requested metadata format) */
 #define          MC_CMD_PARSER_DISP_RW_IN_LUE_VERSIONED_METADATA  0x3
+/* enum: RX0 dispatcher CPU (alias for RX_DICPU; Medford has 2 RX DICPUs) */
+#define          MC_CMD_PARSER_DISP_RW_IN_RX0_DICPU  0x0
+/* enum: RX1 dispatcher CPU (only valid for Medford) */
+#define          MC_CMD_PARSER_DISP_RW_IN_RX1_DICPU  0x4
+/* enum: Miscellaneous other state (only valid for Medford) */
+#define          MC_CMD_PARSER_DISP_RW_IN_MISC_STATE  0x5
 /* identifies the type of operation requested */
 #define       MC_CMD_PARSER_DISP_RW_IN_OP_OFST 4
 /* enum: read a word of DICPU DMEM or a LUE entry */
@@ -6382,8 +6781,12 @@
 #define          MC_CMD_PARSER_DISP_RW_IN_WRITE  0x1
 /* enum: read-modify-write a word of DICPU DMEM (not valid for LUE) */
 #define          MC_CMD_PARSER_DISP_RW_IN_RMW  0x2
-/* data memory address or LUE index */
+/* data memory address (DICPU targets) or LUE index (LUE targets) */
 #define       MC_CMD_PARSER_DISP_RW_IN_ADDRESS_OFST 8
+/* selector (for MISC_STATE target) */
+#define       MC_CMD_PARSER_DISP_RW_IN_SELECTOR_OFST 8
+/* enum: Port to datapath mapping */
+#define          MC_CMD_PARSER_DISP_RW_IN_PORT_DP_MAPPING  0x1
 /* value to write (for DMEM writes) */
 #define       MC_CMD_PARSER_DISP_RW_IN_DMEM_WRITE_VALUE_OFST 12
 /* XOR value (for DMEM read-modify-writes: new = (old & mask) ^ value) */
@@ -6408,6 +6811,12 @@
  */
 #define       MC_CMD_PARSER_DISP_RW_OUT_LUE_MGR_STATE_OFST 20
 #define       MC_CMD_PARSER_DISP_RW_OUT_LUE_MGR_STATE_LEN 32
+/* datapath(s) used for each port (for MISC_STATE PORT_DP_MAPPING selector) */
+#define       MC_CMD_PARSER_DISP_RW_OUT_PORT_DP_MAPPING_OFST 0
+#define       MC_CMD_PARSER_DISP_RW_OUT_PORT_DP_MAPPING_LEN 4
+#define       MC_CMD_PARSER_DISP_RW_OUT_PORT_DP_MAPPING_NUM 4
+#define          MC_CMD_PARSER_DISP_RW_OUT_DP0  0x1 /* enum */
+#define          MC_CMD_PARSER_DISP_RW_OUT_DP1  0x2 /* enum */
 
 
 /***********************************/
@@ -7071,6 +7480,24 @@
 #define    MC_CMD_GET_CAPABILITIES_OUT_LEN 20
 /* First word of flags. */
 #define       MC_CMD_GET_CAPABILITIES_OUT_FLAGS1_OFST 0
+#define        MC_CMD_GET_CAPABILITIES_OUT_VPORT_RECONFIGURE_LBN 3
+#define        MC_CMD_GET_CAPABILITIES_OUT_VPORT_RECONFIGURE_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_TX_STRIPING_LBN 4
+#define        MC_CMD_GET_CAPABILITIES_OUT_TX_STRIPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_VADAPTOR_QUERY_LBN 5
+#define        MC_CMD_GET_CAPABILITIES_OUT_VADAPTOR_QUERY_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_EVB_PORT_VLAN_RESTRICT_LBN 6
+#define        MC_CMD_GET_CAPABILITIES_OUT_EVB_PORT_VLAN_RESTRICT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_DRV_ATTACH_PREBOOT_LBN 7
+#define        MC_CMD_GET_CAPABILITIES_OUT_DRV_ATTACH_PREBOOT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_FORCE_EVENT_MERGING_LBN 8
+#define        MC_CMD_GET_CAPABILITIES_OUT_RX_FORCE_EVENT_MERGING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_SET_MAC_ENHANCED_LBN 9
+#define        MC_CMD_GET_CAPABILITIES_OUT_SET_MAC_ENHANCED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_UNKNOWN_UCAST_DST_FILTER_ALWAYS_MULTI_RECIPIENT_LBN 10
+#define        MC_CMD_GET_CAPABILITIES_OUT_UNKNOWN_UCAST_DST_FILTER_ALWAYS_MULTI_RECIPIENT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_VADAPTOR_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_LBN 11
+#define        MC_CMD_GET_CAPABILITIES_OUT_VADAPTOR_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_TX_MAC_SECURITY_FILTERING_LBN 12
 #define        MC_CMD_GET_CAPABILITIES_OUT_TX_MAC_SECURITY_FILTERING_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_ADDITIONAL_RSS_MODES_LBN 13
@@ -7138,6 +7565,8 @@
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_TEST_FW_RX_HDR_SPLIT  0x107
 /* enum: RXDP Test firmware image 8 */
 #define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_TEST_FW_DISABLE_DL  0x108
+/* enum: RXDP Test firmware image 9 */
+#define          MC_CMD_GET_CAPABILITIES_OUT_RXDP_TEST_FW_DOORBELL_DELAY  0x10b
 /* TxDPCPU firmware id. */
 #define       MC_CMD_GET_CAPABILITIES_OUT_TX_DPCPU_FW_ID_OFST 6
 #define       MC_CMD_GET_CAPABILITIES_OUT_TX_DPCPU_FW_ID_LEN 2
@@ -7153,6 +7582,8 @@
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_TEST_FW_TSO_EDIT  0x101
 /* enum: TXDP Test firmware image 2 */
 #define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_TEST_FW_PACKET_EDITS  0x102
+/* enum: TXDP CSR bus test firmware */
+#define          MC_CMD_GET_CAPABILITIES_OUT_TXDP_TEST_FW_CSR  0x103
 #define       MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_VERSION_OFST 8
 #define       MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_VERSION_LEN 2
 #define        MC_CMD_GET_CAPABILITIES_OUT_RXPD_FW_VERSION_REV_LBN 0
@@ -7227,6 +7658,258 @@
 /* Licensed capabilities */
 #define       MC_CMD_GET_CAPABILITIES_OUT_LICENSE_CAPABILITIES_OFST 16
 
+/* MC_CMD_GET_CAPABILITIES_V2_IN msgrequest */
+#define    MC_CMD_GET_CAPABILITIES_V2_IN_LEN 0
+
+/* MC_CMD_GET_CAPABILITIES_V2_OUT msgresponse */
+#define    MC_CMD_GET_CAPABILITIES_V2_OUT_LEN 72
+/* First word of flags. */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_FLAGS1_OFST 0
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VPORT_RECONFIGURE_LBN 3
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VPORT_RECONFIGURE_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_STRIPING_LBN 4
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_STRIPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VADAPTOR_QUERY_LBN 5
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VADAPTOR_QUERY_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVB_PORT_VLAN_RESTRICT_LBN 6
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVB_PORT_VLAN_RESTRICT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_DRV_ATTACH_PREBOOT_LBN 7
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_DRV_ATTACH_PREBOOT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_FORCE_EVENT_MERGING_LBN 8
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_FORCE_EVENT_MERGING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_SET_MAC_ENHANCED_LBN 9
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_SET_MAC_ENHANCED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_UNKNOWN_UCAST_DST_FILTER_ALWAYS_MULTI_RECIPIENT_LBN 10
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_UNKNOWN_UCAST_DST_FILTER_ALWAYS_MULTI_RECIPIENT_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VADAPTOR_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_LBN 11
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VADAPTOR_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_MAC_SECURITY_FILTERING_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_MAC_SECURITY_FILTERING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_ADDITIONAL_RSS_MODES_LBN 13
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_ADDITIONAL_RSS_MODES_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_QBB_LBN 14
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_QBB_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PACKED_STREAM_VAR_BUFFERS_LBN 15
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PACKED_STREAM_VAR_BUFFERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_RSS_LIMITED_LBN 16
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_RSS_LIMITED_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PACKED_STREAM_LBN 17
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PACKED_STREAM_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_INCLUDE_FCS_LBN 18
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_INCLUDE_FCS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_VLAN_INSERTION_LBN 19
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_VLAN_INSERTION_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_VLAN_STRIPPING_LBN 20
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_VLAN_STRIPPING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_LBN 21
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PREFIX_LEN_0_LBN 22
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PREFIX_LEN_0_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PREFIX_LEN_14_LBN 23
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_PREFIX_LEN_14_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_TIMESTAMP_LBN 24
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_TIMESTAMP_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_BATCHING_LBN 25
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_BATCHING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_MCAST_FILTER_CHAINING_LBN 26
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_MCAST_FILTER_CHAINING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_PM_AND_RXDP_COUNTERS_LBN 27
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_PM_AND_RXDP_COUNTERS_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_DISABLE_SCATTER_LBN 28
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_DISABLE_SCATTER_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_MCAST_UDP_LOOPBACK_LBN 29
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_MCAST_UDP_LOOPBACK_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVB_LBN 30
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVB_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VXLAN_NVGRE_LBN 31
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_VXLAN_NVGRE_WIDTH 1
+/* RxDPCPU firmware id. */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_RX_DPCPU_FW_ID_OFST 4
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_RX_DPCPU_FW_ID_LEN 2
+/* enum: Standard RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP  0x0
+/* enum: Low latency RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_LOW_LATENCY  0x1
+/* enum: Packed stream RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_PACKED_STREAM  0x2
+/* enum: BIST RXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_BIST  0x10a
+/* enum: RXDP Test firmware image 1 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_TO_MC_CUT_THROUGH  0x101
+/* enum: RXDP Test firmware image 2 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_TO_MC_STORE_FORWARD  0x102
+/* enum: RXDP Test firmware image 3 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_TO_MC_STORE_FORWARD_FIRST  0x103
+/* enum: RXDP Test firmware image 4 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_EVERY_EVENT_BATCHABLE  0x104
+/* enum: RXDP Test firmware image 5 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_BACKPRESSURE  0x105
+/* enum: RXDP Test firmware image 6 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_PACKET_EDITS  0x106
+/* enum: RXDP Test firmware image 7 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_RX_HDR_SPLIT  0x107
+/* enum: RXDP Test firmware image 8 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_DISABLE_DL  0x108
+/* enum: RXDP Test firmware image 9 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXDP_TEST_FW_DOORBELL_DELAY  0x10b
+/* TxDPCPU firmware id. */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TX_DPCPU_FW_ID_OFST 6
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TX_DPCPU_FW_ID_LEN 2
+/* enum: Standard TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP  0x0
+/* enum: Low latency TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP_LOW_LATENCY  0x1
+/* enum: High packet rate TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP_HIGH_PACKET_RATE  0x3
+/* enum: BIST TXDP firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP_BIST  0x12d
+/* enum: TXDP Test firmware image 1 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP_TEST_FW_TSO_EDIT  0x101
+/* enum: TXDP Test firmware image 2 */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP_TEST_FW_PACKET_EDITS  0x102
+/* enum: TXDP CSR bus test firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXDP_TEST_FW_CSR  0x103
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_VERSION_OFST 8
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_VERSION_LEN 2
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_VERSION_REV_LBN 0
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_VERSION_REV_WIDTH 12
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_VERSION_TYPE_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_VERSION_TYPE_WIDTH 4
+/* enum: reserved value - do not use (may indicate alternative interpretation
+ * of REV field in future)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_RESERVED  0x0
+/* enum: Trivial RX PD firmware for early Huntington development (Huntington
+ * development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_FIRST_PKT  0x1
+/* enum: RX PD firmware with approximately Siena-compatible behaviour
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_SIENA_COMPAT  0x2
+/* enum: Virtual switching (full feature) RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_VSWITCH  0x3
+/* enum: siena_compat variant RX PD firmware using PM rather than MAC
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_SIENA_COMPAT_PM  0x4
+/* enum: Low latency RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_LOW_LATENCY  0x5
+/* enum: Packed stream RX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_PACKED_STREAM  0x6
+/* enum: RX PD firmware handling layer 2 only for high packet rate performance
+ * tests (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
+/* enum: RX PD firmware parsing but not filtering network overlay tunnel
+ * encapsulations (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_RXPD_FW_TYPE_TESTFW_ENCAP_PARSING_ONLY  0xf
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_VERSION_OFST 10
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_VERSION_LEN 2
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_VERSION_REV_LBN 0
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_VERSION_REV_WIDTH 12
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_VERSION_TYPE_LBN 12
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_VERSION_TYPE_WIDTH 4
+/* enum: reserved value - do not use (may indicate alternative interpretation
+ * of REV field in future)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_RESERVED  0x0
+/* enum: Trivial TX PD firmware for early Huntington development (Huntington
+ * development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_FIRST_PKT  0x1
+/* enum: TX PD firmware with approximately Siena-compatible behaviour
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_SIENA_COMPAT  0x2
+/* enum: Virtual switching (full feature) TX PD production firmware */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_VSWITCH  0x3
+/* enum: siena_compat variant TX PD firmware using PM rather than MAC
+ * (Huntington development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_SIENA_COMPAT_PM  0x4
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_LOW_LATENCY  0x5 /* enum */
+/* enum: TX PD firmware handling layer 2 only for high packet rate performance
+ * tests (Medford development only)
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_LAYER2_PERF  0x7
+/* enum: RX PD firmware for GUE parsing prototype (Medford development only) */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_TXPD_FW_TYPE_TESTFW_GUE_PROTOTYPE  0xe
+/* Hardware capabilities of NIC */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_HW_CAPABILITIES_OFST 12
+/* Licensed capabilities */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_LICENSE_CAPABILITIES_OFST 16
+/* Second word of flags. Not present on older firmware (check the length). */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_FLAGS2_OFST 20
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_LBN 0
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_ENCAP_LBN 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_ENCAP_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVQ_TIMER_CTRL_LBN 2
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVQ_TIMER_CTRL_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVENT_CUT_THROUGH_LBN 3
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_EVENT_CUT_THROUGH_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_CUT_THROUGH_LBN 4
+#define        MC_CMD_GET_CAPABILITIES_V2_OUT_RX_CUT_THROUGH_WIDTH 1
+/* Number of FATSOv2 contexts per datapath supported by this NIC. Not present
+ * on older firmware (check the length).
+ */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_N_CONTEXTS_OFST 24
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TX_TSO_V2_N_CONTEXTS_LEN 2
+/* One byte per PF containing the number of the external port assigned to this
+ * PF, indexed by PF number. Special values indicate that a PF is either not
+ * present or not assigned.
+ */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_PFS_TO_PORTS_ASSIGNMENT_OFST 26
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_PFS_TO_PORTS_ASSIGNMENT_LEN 1
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_PFS_TO_PORTS_ASSIGNMENT_NUM 16
+/* enum: The caller is not permitted to access information on this PF. */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_ACCESS_NOT_PERMITTED  0xff
+/* enum: PF does not exist. */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_PF_NOT_PRESENT  0xfe
+/* enum: PF does exist but is not assigned to any external port. */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_PF_NOT_ASSIGNED  0xfd
+/* enum: This value indicates that PF is assigned, but it cannot be expressed
+ * in this field. It is intended for a possible future situation where a more
+ * complex scheme of PFs to ports mapping is being used. The future driver
+ * should look for a new field supporting the new scheme. The current/old
+ * driver should treat this value as PF_NOT_ASSIGNED.
+ */
+#define          MC_CMD_GET_CAPABILITIES_V2_OUT_INCOMPATIBLE_ASSIGNMENT  0xfc
+/* One byte per PF containing the number of its VFs, indexed by PF number. A
+ * special value indicates that a PF is not present.
+ */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_VFS_PER_PF_OFST 42
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_VFS_PER_PF_LEN 1
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_VFS_PER_PF_NUM 16
+/* enum: The caller is not permitted to access information on this PF. */
+/*               MC_CMD_GET_CAPABILITIES_V2_OUT_ACCESS_NOT_PERMITTED  0xff */
+/* enum: PF does not exist. */
+/*               MC_CMD_GET_CAPABILITIES_V2_OUT_PF_NOT_PRESENT  0xfe */
+/* Number of VIs available for each external port */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_VIS_PER_PORT_OFST 58
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_VIS_PER_PORT_LEN 2
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_VIS_PER_PORT_NUM 4
+/* Size of RX descriptor cache expressed as binary logarithm The actual size
+ * equals (2 ^ RX_DESC_CACHE_SIZE)
+ */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_RX_DESC_CACHE_SIZE_OFST 66
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_RX_DESC_CACHE_SIZE_LEN 1
+/* Size of TX descriptor cache expressed as binary logarithm The actual size
+ * equals (2 ^ TX_DESC_CACHE_SIZE)
+ */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TX_DESC_CACHE_SIZE_OFST 67
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_TX_DESC_CACHE_SIZE_LEN 1
+/* Total number of available PIO buffers */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_PIO_BUFFS_OFST 68
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_NUM_PIO_BUFFS_LEN 2
+/* Size of a single PIO buffer */
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_SIZE_PIO_BUFF_OFST 70
+#define       MC_CMD_GET_CAPABILITIES_V2_OUT_SIZE_PIO_BUFF_LEN 2
+
 
 /***********************************/
 /* MC_CMD_V2_EXTN
@@ -7475,6 +8158,25 @@
 
 
 /***********************************/
+/* MC_CMD_VSWITCH_QUERY
+ * read some config of v-switch. For now this command is an empty placeholder.
+ * It may be used to check if a v-switch is connected to a given EVB port (if
+ * not, then the command returns ENOENT).
+ */
+#define MC_CMD_VSWITCH_QUERY 0x63
+
+#define MC_CMD_0x63_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_VSWITCH_QUERY_IN msgrequest */
+#define    MC_CMD_VSWITCH_QUERY_IN_LEN 4
+/* The port to which the v-switch is connected. */
+#define       MC_CMD_VSWITCH_QUERY_IN_UPSTREAM_PORT_ID_OFST 0
+
+/* MC_CMD_VSWITCH_QUERY_OUT msgresponse */
+#define    MC_CMD_VSWITCH_QUERY_OUT_LEN 0
+
+
+/***********************************/
 /* MC_CMD_VPORT_ALLOC
  * allocate a v-port.
  */
@@ -7510,6 +8212,8 @@
 #define       MC_CMD_VPORT_ALLOC_IN_FLAGS_OFST 8
 #define        MC_CMD_VPORT_ALLOC_IN_FLAG_AUTO_PORT_LBN 0
 #define        MC_CMD_VPORT_ALLOC_IN_FLAG_AUTO_PORT_WIDTH 1
+#define        MC_CMD_VPORT_ALLOC_IN_FLAG_VLAN_RESTRICT_LBN 1
+#define        MC_CMD_VPORT_ALLOC_IN_FLAG_VLAN_RESTRICT_WIDTH 1
 /* The number of VLAN tags to insert/remove. An error will be returned if
  * incompatible with the number of VLAN tags specified for the upstream
  * v-switch.
@@ -7561,6 +8265,8 @@
 #define       MC_CMD_VADAPTOR_ALLOC_IN_FLAGS_OFST 8
 #define        MC_CMD_VADAPTOR_ALLOC_IN_FLAG_AUTO_VADAPTOR_LBN 0
 #define        MC_CMD_VADAPTOR_ALLOC_IN_FLAG_AUTO_VADAPTOR_WIDTH 1
+#define        MC_CMD_VADAPTOR_ALLOC_IN_FLAG_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_LBN 1
+#define        MC_CMD_VADAPTOR_ALLOC_IN_FLAG_PERMIT_SET_MAC_WHEN_FILTERS_INSTALLED_WIDTH 1
 /* The number of VLAN tags to strip on receive */
 #define       MC_CMD_VADAPTOR_ALLOC_IN_NUM_VLANS_OFST 12
 /* The number of VLAN tags to transparently insert/remove. */
@@ -7639,6 +8345,29 @@
 
 
 /***********************************/
+/* MC_CMD_VADAPTOR_QUERY
+ * read some config of v-adaptor.
+ */
+#define MC_CMD_VADAPTOR_QUERY 0x61
+
+#define MC_CMD_0x61_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_VADAPTOR_QUERY_IN msgrequest */
+#define    MC_CMD_VADAPTOR_QUERY_IN_LEN 4
+/* The port to which the v-adaptor is connected. */
+#define       MC_CMD_VADAPTOR_QUERY_IN_UPSTREAM_PORT_ID_OFST 0
+
+/* MC_CMD_VADAPTOR_QUERY_OUT msgresponse */
+#define    MC_CMD_VADAPTOR_QUERY_OUT_LEN 12
+/* The EVB port flags as defined at MC_CMD_VPORT_ALLOC. */
+#define       MC_CMD_VADAPTOR_QUERY_OUT_PORT_FLAGS_OFST 0
+/* The v-adaptor flags as defined at MC_CMD_VADAPTOR_ALLOC. */
+#define       MC_CMD_VADAPTOR_QUERY_OUT_VADAPTOR_FLAGS_OFST 4
+/* The number of VLAN tags that may still be added */
+#define       MC_CMD_VADAPTOR_QUERY_OUT_NUM_AVAILABLE_VLAN_TAGS_OFST 8
+
+
+/***********************************/
 /* MC_CMD_EVB_PORT_ASSIGN
  * assign a port to a PCI function.
  */
@@ -7875,10 +8604,17 @@
 #define    MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_LEN 8
 /* The handle of the RSS context */
 #define       MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_RSS_CONTEXT_ID_OFST 0
-/* Hash control flags. The _EN bits are always supported. The _MODE bits only
- * work when the firmware reports ADDITIONAL_RSS_MODES in
- * MC_CMD_GET_CAPABILITIES and override the _EN bits if any of them are not 0.
- * See the RSS_MODE structure for the meaning of the mode bits.
+/* Hash control flags. The _EN bits are always supported, but new modes are
+ * available when ADDITIONAL_RSS_MODES is reported by MC_CMD_GET_CAPABILITIES:
+ * in this case, the MODE fields may be set to non-zero values, and will take
+ * effect regardless of the settings of the _EN flags. See the RSS_MODE
+ * structure for the meaning of the mode bits. Drivers must check the
+ * capability before trying to set any _MODE fields, as older firmware will
+ * reject any attempt to set the FLAGS field to a value > 0xff with EINVAL. In
+ * the case where all the _MODE flags are zero, the _EN flags take effect,
+ * providing backward compatibility for existing drivers. (Setting all _MODE
+ * *and* all _EN flags to zero is valid, to disable RSS spreading for that
+ * particular packet type.)
  */
 #define       MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_FLAGS_OFST 4
 #define        MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_TOEPLITZ_IPV4_EN_LBN 0
@@ -7923,11 +8659,18 @@
 
 /* MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT msgresponse */
 #define    MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_LEN 8
-/* Hash control flags. If any _MODE bits are non-zero (which will only be true
- * when the firmware reports ADDITIONAL_RSS_MODES) then the _EN bits should be
- * disregarded (but are guaranteed to be consistent with the _MODE bits if
- * RSS_CONTEXT_SET_FLAGS has never been called for this context since it was
- * allocated).
+/* Hash control flags. If all _MODE bits are zero (which will always be true
+ * for older firmware which does not report the ADDITIONAL_RSS_MODES
+ * capability), the _EN bits report the state. If any _MODE bits are non-zero
+ * (which will only be true when the firmware reports ADDITIONAL_RSS_MODES)
+ * then the _EN bits should be disregarded, although the _MODE flags are
+ * guaranteed to be consistent with the _EN flags for a freshly-allocated RSS
+ * context and in the case where the _EN flags were used in the SET. This
+ * provides backward compatibility: old drivers will not be attempting to
+ * derive any meaning from the _MODE bits (and can never set them to any value
+ * not representable by the _EN bits); new drivers can always determine the
+ * mode by looking only at the _MODE bits; the value returned by a GET can
+ * always be used for a SET regardless of old/new driver vs. old/new firmware.
  */
 #define       MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_FLAGS_OFST 4
 #define        MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_IPV4_EN_LBN 0
@@ -8155,6 +8898,74 @@
 
 
 /***********************************/
+/* MC_CMD_VPORT_RECONFIGURE
+ * Replace VLAN tags and/or MAC addresses of an existing v-port. If the v-port
+ * has already been passed to another function (v-port's user), then that
+ * function will be reset before applying the changes.
+ */
+#define MC_CMD_VPORT_RECONFIGURE 0xeb
+
+#define MC_CMD_0xeb_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_VPORT_RECONFIGURE_IN msgrequest */
+#define    MC_CMD_VPORT_RECONFIGURE_IN_LEN 44
+/* The handle of the v-port */
+#define       MC_CMD_VPORT_RECONFIGURE_IN_VPORT_ID_OFST 0
+/* Flags requesting what should be changed. */
+#define       MC_CMD_VPORT_RECONFIGURE_IN_FLAGS_OFST 4
+#define        MC_CMD_VPORT_RECONFIGURE_IN_REPLACE_VLAN_TAGS_LBN 0
+#define        MC_CMD_VPORT_RECONFIGURE_IN_REPLACE_VLAN_TAGS_WIDTH 1
+#define        MC_CMD_VPORT_RECONFIGURE_IN_REPLACE_MACADDRS_LBN 1
+#define        MC_CMD_VPORT_RECONFIGURE_IN_REPLACE_MACADDRS_WIDTH 1
+/* The number of VLAN tags to insert/remove. An error will be returned if
+ * incompatible with the number of VLAN tags specified for the upstream
+ * v-switch.
+ */
+#define       MC_CMD_VPORT_RECONFIGURE_IN_NUM_VLAN_TAGS_OFST 8
+/* The actual VLAN tags to insert/remove */
+#define       MC_CMD_VPORT_RECONFIGURE_IN_VLAN_TAGS_OFST 12
+#define        MC_CMD_VPORT_RECONFIGURE_IN_VLAN_TAG_0_LBN 0
+#define        MC_CMD_VPORT_RECONFIGURE_IN_VLAN_TAG_0_WIDTH 16
+#define        MC_CMD_VPORT_RECONFIGURE_IN_VLAN_TAG_1_LBN 16
+#define        MC_CMD_VPORT_RECONFIGURE_IN_VLAN_TAG_1_WIDTH 16
+/* The number of MAC addresses to add */
+#define       MC_CMD_VPORT_RECONFIGURE_IN_NUM_MACADDRS_OFST 16
+/* MAC addresses to add */
+#define       MC_CMD_VPORT_RECONFIGURE_IN_MACADDRS_OFST 20
+#define       MC_CMD_VPORT_RECONFIGURE_IN_MACADDRS_LEN 6
+#define       MC_CMD_VPORT_RECONFIGURE_IN_MACADDRS_NUM 4
+
+/* MC_CMD_VPORT_RECONFIGURE_OUT msgresponse */
+#define    MC_CMD_VPORT_RECONFIGURE_OUT_LEN 4
+#define       MC_CMD_VPORT_RECONFIGURE_OUT_FLAGS_OFST 0
+#define        MC_CMD_VPORT_RECONFIGURE_OUT_RESET_DONE_LBN 0
+#define        MC_CMD_VPORT_RECONFIGURE_OUT_RESET_DONE_WIDTH 1
+
+
+/***********************************/
+/* MC_CMD_EVB_PORT_QUERY
+ * read some config of v-port.
+ */
+#define MC_CMD_EVB_PORT_QUERY 0x62
+
+#define MC_CMD_0x62_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_EVB_PORT_QUERY_IN msgrequest */
+#define    MC_CMD_EVB_PORT_QUERY_IN_LEN 4
+/* The handle of the v-port */
+#define       MC_CMD_EVB_PORT_QUERY_IN_PORT_ID_OFST 0
+
+/* MC_CMD_EVB_PORT_QUERY_OUT msgresponse */
+#define    MC_CMD_EVB_PORT_QUERY_OUT_LEN 8
+/* The EVB port flags as defined at MC_CMD_VPORT_ALLOC. */
+#define       MC_CMD_EVB_PORT_QUERY_OUT_PORT_FLAGS_OFST 0
+/* The number of VLAN tags that may be used on a v-adaptor connected to this
+ * EVB port.
+ */
+#define       MC_CMD_EVB_PORT_QUERY_OUT_NUM_AVAILABLE_VLAN_TAGS_OFST 4
+
+
+/***********************************/
 /* MC_CMD_DUMP_BUFTBL_ENTRIES
  * Dump buffer table entries, mainly for command client debug use. Dumps
  * absolute entries, and does not use chunk handles. All entries must be in
@@ -8196,6 +9007,14 @@
 #define       MC_CMD_SET_RXDP_CONFIG_IN_DATA_OFST 0
 #define        MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_DMA_LBN 0
 #define        MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_DMA_WIDTH 1
+#define        MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_LEN_LBN 1
+#define        MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_LEN_WIDTH 2
+/* enum: pad to 64 bytes */
+#define          MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_64  0x0
+/* enum: pad to 128 bytes (Medford only) */
+#define          MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_128  0x1
+/* enum: pad to 256 bytes (Medford only) */
+#define          MC_CMD_SET_RXDP_CONFIG_IN_PAD_HOST_256   0x2
 
 /* MC_CMD_SET_RXDP_CONFIG_OUT msgresponse */
 #define    MC_CMD_SET_RXDP_CONFIG_OUT_LEN 0
@@ -8217,6 +9036,10 @@
 #define       MC_CMD_GET_RXDP_CONFIG_OUT_DATA_OFST 0
 #define        MC_CMD_GET_RXDP_CONFIG_OUT_PAD_HOST_DMA_LBN 0
 #define        MC_CMD_GET_RXDP_CONFIG_OUT_PAD_HOST_DMA_WIDTH 1
+#define        MC_CMD_GET_RXDP_CONFIG_OUT_PAD_HOST_LEN_LBN 1
+#define        MC_CMD_GET_RXDP_CONFIG_OUT_PAD_HOST_LEN_WIDTH 2
+/*             Enum values, see field(s): */
+/*                MC_CMD_SET_RXDP_CONFIG/MC_CMD_SET_RXDP_CONFIG_IN/PAD_HOST_LEN */
 
 
 /***********************************/
@@ -8788,32 +9611,38 @@
 #define       MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_MAXNUM 63
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_ID_LBN 0
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_ID_WIDTH 8
-/* enum: Attenuation (0-15, TBD for Medford) */
+/* enum: Attenuation (0-15, Huntington) */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_ATT  0x0
-/* enum: CTLE Boost (0-15, TBD for Medford) */
+/* enum: CTLE Boost (0-15, Huntington) */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_BOOST  0x1
-/* enum: Edge DFE Tap1 (0 - max negative, 64 - zero, 127 - max positive, TBD
- * for Medford)
+/* enum: Edge DFE Tap1 (Huntington - 0 - max negative, 64 - zero, 127 - max
+ * positive, Medford - 0-31)
  */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP1  0x2
-/* enum: Edge DFE Tap2 (0 - max negative, 32 - zero, 63 - max positive, TBD for
- * Medford)
+/* enum: Edge DFE Tap2 (Huntington - 0 - max negative, 32 - zero, 63 - max
+ * positive, Medford - 0-31)
  */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP2  0x3
-/* enum: Edge DFE Tap3 (0 - max negative, 32 - zero, 63 - max positive, TBD for
- * Medford)
+/* enum: Edge DFE Tap3 (Huntington - 0 - max negative, 32 - zero, 63 - max
+ * positive, Medford - 0-16)
  */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP3  0x4
-/* enum: Edge DFE Tap4 (0 - max negative, 32 - zero, 63 - max positive, TBD for
- * Medford)
+/* enum: Edge DFE Tap4 (Huntington - 0 - max negative, 32 - zero, 63 - max
+ * positive, Medford - 0-16)
  */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP4  0x5
-/* enum: Edge DFE Tap5 (0 - max negative, 32 - zero, 63 - max positive, TBD for
- * Medford)
+/* enum: Edge DFE Tap5 (Huntington - 0 - max negative, 32 - zero, 63 - max
+ * positive, Medford - 0-16)
  */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_TAP5  0x6
-/* enum: Edge DFE DLEV (TBD for Medford) */
+/* enum: Edge DFE DLEV (0-128 for Medford) */
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_EDFE_DLEV  0x7
+/* enum: Variable Gain Amplifier (0-15, Medford) */
+#define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_VGA  0x8
+/* enum: CTLE EQ Capacitor (0-15, Medford) */
+#define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_CTLE_EQC  0x9
+/* enum: CTLE EQ Resistor (0-7, Medford) */
+#define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_CTLE_EQRES  0xa
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_LANE_LBN 8
 #define        MC_CMD_KR_TUNE_RXEQ_GET_OUT_PARAM_LANE_WIDTH 3
 #define          MC_CMD_KR_TUNE_RXEQ_GET_OUT_LANE_0  0x0 /* enum */
@@ -8885,26 +9714,32 @@
 #define       MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_MAXNUM 63
 #define        MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_ID_LBN 0
 #define        MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_ID_WIDTH 8
-/* enum: TX Amplitude */
+/* enum: TX Amplitude (Huntington, Medford) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_LEV  0x0
-/* enum: De-Emphasis Tap1 Magnitude (0-7) */
+/* enum: De-Emphasis Tap1 Magnitude (0-7) (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_MODE  0x1
 /* enum: De-Emphasis Tap1 Fine */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_DTLEV  0x2
-/* enum: De-Emphasis Tap2 Magnitude (0-6) */
+/* enum: De-Emphasis Tap2 Magnitude (0-6) (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_D2  0x3
-/* enum: De-Emphasis Tap2 Fine */
+/* enum: De-Emphasis Tap2 Fine (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_D2TLEV  0x4
-/* enum: Pre-Emphasis Magnitude */
+/* enum: Pre-Emphasis Magnitude (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_E  0x5
-/* enum: Pre-Emphasis Fine */
+/* enum: Pre-Emphasis Fine (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_ETLEV  0x6
-/* enum: TX Slew Rate Coarse control */
+/* enum: TX Slew Rate Coarse control (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_PREDRV_DLY  0x7
-/* enum: TX Slew Rate Fine control */
+/* enum: TX Slew Rate Fine control (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_SR_SET  0x8
-/* enum: TX Termination Impedance control */
+/* enum: TX Termination Impedance control (Huntington) */
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_RT_SET  0x9
+/* enum: TX Amplitude Fine control (Medford) */
+#define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TX_LEV_FINE  0xa
+/* enum: Pre-shoot Tap (Medford) */
+#define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TAP_ADV  0xb
+/* enum: De-emphasis Tap (Medford) */
+#define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_TAP_DLY  0xc
 #define        MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_LANE_LBN 8
 #define        MC_CMD_KR_TUNE_TXEQ_GET_OUT_PARAM_LANE_WIDTH 3
 #define          MC_CMD_KR_TUNE_TXEQ_GET_OUT_LANE_0  0x0 /* enum */
@@ -9086,8 +9921,16 @@
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_DFE_TAP4  0x5
 /* enum: DFE Tap5 (0 - max negative, 32 - zero, 63 - max positive) */
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_DFE_TAP5  0x6
+/* enum: DFE DLev */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_DFE_DLEV  0x7
+/* enum: Figure of Merit */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_FOM  0x8
+/* enum: CTLE EQ Capacitor (HF Gain) */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_CTLE_EQC  0x9
+/* enum: CTLE EQ Resistor (DC Gain) */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_CTLE_EQRES  0xa
 #define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_LANE_LBN 8
-#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_LANE_WIDTH 4
+#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_LANE_WIDTH 5
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_0  0x0 /* enum */
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_1  0x1 /* enum */
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_2  0x2 /* enum */
@@ -9096,12 +9939,57 @@
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_5  0x5 /* enum */
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_6  0x6 /* enum */
 #define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_7  0x7 /* enum */
-#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_ALL  0x8 /* enum */
-#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_RESERVED_LBN 12
-#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_RESERVED_WIDTH 12
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_8  0x8 /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_9  0x9 /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_10  0xa /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_11  0xb /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_12  0xc /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_13  0xd /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_14  0xe /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_15  0xf /* enum */
+#define          MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_LANE_ALL  0x10 /* enum */
+#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_AUTOCAL_LBN 13
+#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_AUTOCAL_WIDTH 1
+#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_RESERVED_LBN 14
+#define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_RESERVED_WIDTH 10
 #define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_CURRENT_LBN 24
 #define        MC_CMD_PCIE_TUNE_RXEQ_GET_OUT_PARAM_CURRENT_WIDTH 8
 
+/* MC_CMD_PCIE_TUNE_RXEQ_SET_IN msgrequest */
+#define    MC_CMD_PCIE_TUNE_RXEQ_SET_IN_LENMIN 8
+#define    MC_CMD_PCIE_TUNE_RXEQ_SET_IN_LENMAX 252
+#define    MC_CMD_PCIE_TUNE_RXEQ_SET_IN_LEN(num) (4+4*(num))
+/* Requested operation */
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PCIE_TUNE_OP_OFST 0
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PCIE_TUNE_OP_LEN 1
+/* Align the arguments to 32 bits */
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PCIE_TUNE_RSVD_OFST 1
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PCIE_TUNE_RSVD_LEN 3
+/* RXEQ Parameter */
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_OFST 4
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_LEN 4
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_MINNUM 1
+#define       MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_MAXNUM 62
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_ID_LBN 0
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_ID_WIDTH 8
+/*             Enum values, see field(s): */
+/*                MC_CMD_PCIE_TUNE_RXEQ_GET_OUT/PARAM_ID */
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_LANE_LBN 8
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_LANE_WIDTH 5
+/*             Enum values, see field(s): */
+/*                MC_CMD_PCIE_TUNE_RXEQ_GET_OUT/PARAM_LANE */
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_AUTOCAL_LBN 13
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_AUTOCAL_WIDTH 1
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_RESERVED_LBN 14
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_RESERVED_WIDTH 2
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_INITIAL_LBN 16
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_PARAM_INITIAL_WIDTH 8
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_RESERVED2_LBN 24
+#define        MC_CMD_PCIE_TUNE_RXEQ_SET_IN_RESERVED2_WIDTH 8
+
+/* MC_CMD_PCIE_TUNE_RXEQ_SET_OUT msgresponse */
+#define    MC_CMD_PCIE_TUNE_RXEQ_SET_OUT_LEN 0
+
 /* MC_CMD_PCIE_TUNE_TXEQ_GET_IN msgrequest */
 #define    MC_CMD_PCIE_TUNE_TXEQ_GET_IN_LEN 4
 /* Requested operation */
@@ -9176,6 +10064,7 @@
 /***********************************/
 /* MC_CMD_LICENSING
  * Operations on the NVRAM_PARTITION_TYPE_LICENSE application license partition
+ * - not used for V3 licensing
  */
 #define MC_CMD_LICENSING 0xf3
 
@@ -9220,6 +10109,93 @@
 
 
 /***********************************/
+/* MC_CMD_LICENSING_V3
+ * Operations on the NVRAM_PARTITION_TYPE_LICENSE application license partition
+ * - V3 licensing (Medford)
+ */
+#define MC_CMD_LICENSING_V3 0xd0
+
+#define MC_CMD_0xd0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LICENSING_V3_IN msgrequest */
+#define    MC_CMD_LICENSING_V3_IN_LEN 4
+/* identifies the type of operation requested */
+#define       MC_CMD_LICENSING_V3_IN_OP_OFST 0
+/* enum: re-read and apply licenses after a license key partition update; note
+ * that this operation returns a zero-length response
+ */
+#define          MC_CMD_LICENSING_V3_IN_OP_UPDATE_LICENSE  0x0
+/* enum: report counts of installed licenses */
+#define          MC_CMD_LICENSING_V3_IN_OP_REPORT_LICENSE  0x1
+
+/* MC_CMD_LICENSING_V3_OUT msgresponse */
+#define    MC_CMD_LICENSING_V3_OUT_LEN 88
+/* count of keys which are valid */
+#define       MC_CMD_LICENSING_V3_OUT_VALID_KEYS_OFST 0
+/* sum of UNVERIFIABLE_KEYS + WRONG_NODE_KEYS (for compatibility with
+ * MC_CMD_FC_OP_LICENSE)
+ */
+#define       MC_CMD_LICENSING_V3_OUT_INVALID_KEYS_OFST 4
+/* count of keys which are invalid due to being unverifiable */
+#define       MC_CMD_LICENSING_V3_OUT_UNVERIFIABLE_KEYS_OFST 8
+/* count of keys which are invalid due to being for the wrong node */
+#define       MC_CMD_LICENSING_V3_OUT_WRONG_NODE_KEYS_OFST 12
+/* licensing state (for diagnostics; the exact meaning of the bits in this
+ * field are private to the firmware)
+ */
+#define       MC_CMD_LICENSING_V3_OUT_LICENSING_STATE_OFST 16
+/* licensing subsystem self-test report (for manftest) */
+#define       MC_CMD_LICENSING_V3_OUT_LICENSING_SELF_TEST_OFST 20
+/* enum: licensing subsystem self-test failed */
+#define          MC_CMD_LICENSING_V3_OUT_SELF_TEST_FAIL  0x0
+/* enum: licensing subsystem self-test passed */
+#define          MC_CMD_LICENSING_V3_OUT_SELF_TEST_PASS  0x1
+/* bitmask of licensed applications */
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_APPS_OFST 24
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_APPS_LEN 8
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_APPS_LO_OFST 24
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_APPS_HI_OFST 28
+/* reserved for future use */
+#define       MC_CMD_LICENSING_V3_OUT_RESERVED_0_OFST 32
+#define       MC_CMD_LICENSING_V3_OUT_RESERVED_0_LEN 24
+/* bitmask of licensed features */
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_FEATURES_OFST 56
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_FEATURES_LEN 8
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_FEATURES_LO_OFST 56
+#define       MC_CMD_LICENSING_V3_OUT_LICENSED_FEATURES_HI_OFST 60
+/* reserved for future use */
+#define       MC_CMD_LICENSING_V3_OUT_RESERVED_1_OFST 64
+#define       MC_CMD_LICENSING_V3_OUT_RESERVED_1_LEN 24
+
+
+/***********************************/
+/* MC_CMD_LICENSING_GET_ID_V3
+ * Get ID and type from the NVRAM_PARTITION_TYPE_LICENSE application license
+ * partition - V3 licensing (Medford)
+ */
+#define MC_CMD_LICENSING_GET_ID_V3 0xd1
+
+#define MC_CMD_0xd1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LICENSING_GET_ID_V3_IN msgrequest */
+#define    MC_CMD_LICENSING_GET_ID_V3_IN_LEN 0
+
+/* MC_CMD_LICENSING_GET_ID_V3_OUT msgresponse */
+#define    MC_CMD_LICENSING_GET_ID_V3_OUT_LENMIN 8
+#define    MC_CMD_LICENSING_GET_ID_V3_OUT_LENMAX 252
+#define    MC_CMD_LICENSING_GET_ID_V3_OUT_LEN(num) (8+1*(num))
+/* type of license (eg 3) */
+#define       MC_CMD_LICENSING_GET_ID_V3_OUT_LICENSE_TYPE_OFST 0
+/* length of the license ID (in bytes) */
+#define       MC_CMD_LICENSING_GET_ID_V3_OUT_LICENSE_ID_LENGTH_OFST 4
+/* the unique license ID of the adapter */
+#define       MC_CMD_LICENSING_GET_ID_V3_OUT_LICENSE_ID_OFST 8
+#define       MC_CMD_LICENSING_GET_ID_V3_OUT_LICENSE_ID_LEN 1
+#define       MC_CMD_LICENSING_GET_ID_V3_OUT_LICENSE_ID_MINNUM 0
+#define       MC_CMD_LICENSING_GET_ID_V3_OUT_LICENSE_ID_MAXNUM 244
+
+
+/***********************************/
 /* MC_CMD_MC2MC_PROXY
  * Execute an arbitrary MCDI command on the slave MC of a dual-core device.
  * This will fail on a single-core system.
@@ -9239,7 +10215,7 @@
 /* MC_CMD_GET_LICENSED_APP_STATE
  * Query the state of an individual licensed application. (Note that the actual
  * state may be invalidated by the MC_CMD_LICENSING OP_UPDATE_LICENSE operation
- * or a reboot of the MC.)
+ * or a reboot of the MC.) Not used for V3 licensing
  */
 #define MC_CMD_GET_LICENSED_APP_STATE 0xf5
 
@@ -9261,8 +10237,68 @@
 
 
 /***********************************/
+/* MC_CMD_GET_LICENSED_V3_APP_STATE
+ * Query the state of an individual licensed application. (Note that the actual
+ * state may be invalidated by the MC_CMD_LICENSING_V3 OP_UPDATE_LICENSE
+ * operation or a reboot of the MC.) Used for V3 licensing (Medford)
+ */
+#define MC_CMD_GET_LICENSED_V3_APP_STATE 0xd2
+
+#define MC_CMD_0xd2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_LICENSED_V3_APP_STATE_IN msgrequest */
+#define    MC_CMD_GET_LICENSED_V3_APP_STATE_IN_LEN 8
+/* application ID to query (LICENSED_V3_APPS_xxx) expressed as a single bit
+ * mask
+ */
+#define       MC_CMD_GET_LICENSED_V3_APP_STATE_IN_APP_ID_OFST 0
+#define       MC_CMD_GET_LICENSED_V3_APP_STATE_IN_APP_ID_LEN 8
+#define       MC_CMD_GET_LICENSED_V3_APP_STATE_IN_APP_ID_LO_OFST 0
+#define       MC_CMD_GET_LICENSED_V3_APP_STATE_IN_APP_ID_HI_OFST 4
+
+/* MC_CMD_GET_LICENSED_V3_APP_STATE_OUT msgresponse */
+#define    MC_CMD_GET_LICENSED_V3_APP_STATE_OUT_LEN 4
+/* state of this application */
+#define       MC_CMD_GET_LICENSED_V3_APP_STATE_OUT_STATE_OFST 0
+/* enum: no (or invalid) license is present for the application */
+#define          MC_CMD_GET_LICENSED_V3_APP_STATE_OUT_NOT_LICENSED  0x0
+/* enum: a valid license is present for the application */
+#define          MC_CMD_GET_LICENSED_V3_APP_STATE_OUT_LICENSED  0x1
+
+
+/***********************************/
+/* MC_CMD_GET_LICENSED_V3_FEATURE_STATES
+ * Query the state of an one or more licensed features. (Note that the actual
+ * state may be invalidated by the MC_CMD_LICENSING_V3 OP_UPDATE_LICENSE
+ * operation or a reboot of the MC.) Used for V3 licensing (Medford)
+ */
+#define MC_CMD_GET_LICENSED_V3_FEATURE_STATES 0xd3
+
+#define MC_CMD_0xd3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_GET_LICENSED_V3_FEATURE_STATES_IN msgrequest */
+#define    MC_CMD_GET_LICENSED_V3_FEATURE_STATES_IN_LEN 8
+/* features to query (LICENSED_V3_FEATURES_xxx) expressed as a mask with one or
+ * more bits set
+ */
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_IN_FEATURES_OFST 0
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_IN_FEATURES_LEN 8
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_IN_FEATURES_LO_OFST 0
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_IN_FEATURES_HI_OFST 4
+
+/* MC_CMD_GET_LICENSED_V3_FEATURE_STATES_OUT msgresponse */
+#define    MC_CMD_GET_LICENSED_V3_FEATURE_STATES_OUT_LEN 8
+/* states of these features - bit set for licensed, clear for not licensed */
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_OUT_STATES_OFST 0
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_OUT_STATES_LEN 8
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_OUT_STATES_LO_OFST 0
+#define       MC_CMD_GET_LICENSED_V3_FEATURE_STATES_OUT_STATES_HI_OFST 4
+
+
+/***********************************/
 /* MC_CMD_LICENSED_APP_OP
- * Perform an action for an individual licensed application.
+ * Perform an action for an individual licensed application - not used for V3
+ * licensing.
  */
 #define MC_CMD_LICENSED_APP_OP 0xf6
 
@@ -9328,6 +10364,67 @@
 
 
 /***********************************/
+/* MC_CMD_LICENSED_V3_VALIDATE_APP
+ * Perform validation for an individual licensed application - V3 licensing
+ * (Medford)
+ */
+#define MC_CMD_LICENSED_V3_VALIDATE_APP 0xd4
+
+#define MC_CMD_0xd4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LICENSED_V3_VALIDATE_APP_IN msgrequest */
+#define    MC_CMD_LICENSED_V3_VALIDATE_APP_IN_LEN 72
+/* application ID expressed as a single bit mask */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_OFST 0
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_LEN 8
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_LO_OFST 0
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_APP_ID_HI_OFST 4
+/* challenge for validation */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_CHALLENGE_OFST 8
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_IN_CHALLENGE_LEN 64
+
+/* MC_CMD_LICENSED_V3_VALIDATE_APP_OUT msgresponse */
+#define    MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_LEN 72
+/* application expiry time */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_TIME_OFST 0
+/* application expiry units */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNITS_OFST 4
+/* enum: expiry units are accounting units */
+#define          MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNIT_ACC  0x0
+/* enum: expiry units are calendar days */
+#define          MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_EXPIRY_UNIT_DAYS  0x1
+/* validation response to challenge */
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_RESPONSE_OFST 8
+#define       MC_CMD_LICENSED_V3_VALIDATE_APP_OUT_RESPONSE_LEN 64
+
+
+/***********************************/
+/* MC_CMD_LICENSED_V3_MASK_FEATURES
+ * Mask features - V3 licensing (Medford)
+ */
+#define MC_CMD_LICENSED_V3_MASK_FEATURES 0xd5
+
+#define MC_CMD_0xd5_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
+/* MC_CMD_LICENSED_V3_MASK_FEATURES_IN msgrequest */
+#define    MC_CMD_LICENSED_V3_MASK_FEATURES_IN_LEN 12
+/* mask to be applied to features to be changed */
+#define       MC_CMD_LICENSED_V3_MASK_FEATURES_IN_MASK_OFST 0
+#define       MC_CMD_LICENSED_V3_MASK_FEATURES_IN_MASK_LEN 8
+#define       MC_CMD_LICENSED_V3_MASK_FEATURES_IN_MASK_LO_OFST 0
+#define       MC_CMD_LICENSED_V3_MASK_FEATURES_IN_MASK_HI_OFST 4
+/* whether to turn on or turn off the masked features */
+#define       MC_CMD_LICENSED_V3_MASK_FEATURES_IN_FLAG_OFST 8
+/* enum: turn the features off */
+#define          MC_CMD_LICENSED_V3_MASK_FEATURES_IN_OFF  0x0
+/* enum: turn the features back on */
+#define          MC_CMD_LICENSED_V3_MASK_FEATURES_IN_ON  0x1
+
+/* MC_CMD_LICENSED_V3_MASK_FEATURES_OUT msgresponse */
+#define    MC_CMD_LICENSED_V3_MASK_FEATURES_OUT_LEN 0
+
+
+/***********************************/
 /* MC_CMD_SET_PORT_SNIFF_CONFIG
  * Configure RX port sniffing for the physical port associated with the calling
  * function. Only a privileged function may change the port sniffing
@@ -9696,12 +10793,27 @@
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_ONLOAD            0x4 /* enum */
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_PTP               0x8 /* enum */
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_INSECURE_FILTERS  0x10 /* enum */
-#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_MAC_SPOOFING      0x20 /* enum */
+/* enum: Deprecated. Equivalent to MAC_SPOOFING_TX combined with CHANGE_MAC. */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_MAC_SPOOFING      0x20
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_UNICAST           0x40 /* enum */
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_MULTICAST         0x80 /* enum */
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_BROADCAST         0x100 /* enum */
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_ALL_MULTICAST     0x200 /* enum */
 #define          MC_CMD_PRIVILEGE_MASK_IN_GRP_PROMISCUOUS       0x400 /* enum */
+/* enum: Allows to set the TX packets' source MAC address to any arbitrary MAC
+ * adress.
+ */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_MAC_SPOOFING_TX   0x800
+/* enum: Privilege that allows a Function to change the MAC address configured
+ * in its associated vAdapter/vPort.
+ */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_CHANGE_MAC        0x1000
+/* enum: Privilege that allows a Function to install filters that specify VLANs
+ * that are not in the permit list for the associated vPort. This privilege is
+ * primarily to support ESX where vPorts are created that restrict traffic to
+ * only a set of permitted VLANs. See the vPort flag FLAG_VLAN_RESTRICT.
+ */
+#define          MC_CMD_PRIVILEGE_MASK_IN_GRP_UNRESTRICTED_VLAN  0x2000
 /* enum: Set this bit to indicate that a new privilege mask is to be set,
  * otherwise the command will only read the existing mask.
  */
@@ -9951,7 +11063,7 @@
 /* Sector type */
 #define       MC_CMD_XPM_WRITE_SECTOR_IN_TYPE_OFST 4
 /*            Enum values, see field(s): */
-/*               MC_CMD_XPM_READ_SECTOR_OUT/TYPE */
+/*               MC_CMD_XPM_READ_SECTOR/MC_CMD_XPM_READ_SECTOR_OUT/TYPE */
 /* Sector size */
 #define       MC_CMD_XPM_WRITE_SECTOR_IN_SIZE_OFST 8
 /* Sector data */
@@ -10067,4 +11179,123 @@
 #define    MC_CMD_XPM_WRITE_TEST_OUT_LEN 0
 
 
+/***********************************/
+/* MC_CMD_EXEC_SIGNED
+ * Check the CMAC of the contents of IMEM and DMEM against the value supplied
+ * and if correct begin execution from the start of IMEM. The caller supplies a
+ * key ID, the length of IMEM and DMEM to validate and the expected CMAC. CMAC
+ * computation runs from the start of IMEM, and from the start of DMEM + 16k,
+ * to match flash booting. The command will respond with EINVAL if the CMAC
+ * does match, otherwise it will respond with success before it jumps to IMEM.
+ */
+#define MC_CMD_EXEC_SIGNED 0x10c
+
+#define MC_CMD_0x10c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_EXEC_SIGNED_IN msgrequest */
+#define    MC_CMD_EXEC_SIGNED_IN_LEN 28
+/* the length of code to include in the CMAC */
+#define       MC_CMD_EXEC_SIGNED_IN_CODELEN_OFST 0
+/* the length of date to include in the CMAC */
+#define       MC_CMD_EXEC_SIGNED_IN_DATALEN_OFST 4
+/* the XPM sector containing the key to use */
+#define       MC_CMD_EXEC_SIGNED_IN_KEYSECTOR_OFST 8
+/* the expected CMAC value */
+#define       MC_CMD_EXEC_SIGNED_IN_CMAC_OFST 12
+#define       MC_CMD_EXEC_SIGNED_IN_CMAC_LEN 16
+
+/* MC_CMD_EXEC_SIGNED_OUT msgresponse */
+#define    MC_CMD_EXEC_SIGNED_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_PREPARE_SIGNED
+ * Prepare to upload a signed image. This will scrub the specified length of
+ * the data region, which must be at least as large as the DATALEN supplied to
+ * MC_CMD_EXEC_SIGNED.
+ */
+#define MC_CMD_PREPARE_SIGNED 0x10d
+
+#define MC_CMD_0x10d_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_PREPARE_SIGNED_IN msgrequest */
+#define    MC_CMD_PREPARE_SIGNED_IN_LEN 4
+/* the length of data area to clear */
+#define       MC_CMD_PREPARE_SIGNED_IN_DATALEN_OFST 0
+
+/* MC_CMD_PREPARE_SIGNED_OUT msgresponse */
+#define    MC_CMD_PREPARE_SIGNED_OUT_LEN 0
+
+
+/***********************************/
+/* MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS
+ * Configure UDP ports for tunnel encapsulation hardware acceleration. The
+ * parser-dispatcher will attempt to parse traffic on these ports as tunnel
+ * encapsulation PDUs and filter them using the tunnel encapsulation filter
+ * chain rather than the standard filter chain. Note that this command can
+ * cause all functions to see a reset. (Available on Medford only.)
+ */
+#define MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS 0x117
+
+#define MC_CMD_0x117_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN msgrequest */
+#define    MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_LENMIN 4
+#define    MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_LENMAX 68
+#define    MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_LEN(num) (4+4*(num))
+/* Flags */
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_FLAGS_OFST 0
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_FLAGS_LEN 2
+#define        MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_UNLOADING_LBN 0
+#define        MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_UNLOADING_WIDTH 1
+/* The number of entries in the ENTRIES array */
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_NUM_ENTRIES_OFST 2
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_NUM_ENTRIES_LEN 2
+/* Entries defining the UDP port to protocol mapping, each laid out as a
+ * TUNNEL_ENCAP_UDP_PORT_ENTRY
+ */
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_ENTRIES_OFST 4
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_ENTRIES_LEN 4
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_ENTRIES_MINNUM 0
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_IN_ENTRIES_MAXNUM 16
+
+/* MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT msgresponse */
+#define    MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_LEN 2
+/* Flags */
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_FLAGS_OFST 0
+#define       MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_FLAGS_LEN 2
+#define        MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_RESETTING_LBN 0
+#define        MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS_OUT_RESETTING_WIDTH 1
+
+
+/***********************************/
+/* MC_CMD_RX_BALANCING
+ * Configure a port upconverter to distribute the packets on both RX engines.
+ * Packets are distributed based on a table with the destination vFIFO. The
+ * index of the table is a hash of source and destination of IPV4 and VLAN
+ * priority.
+ */
+#define MC_CMD_RX_BALANCING 0x118
+
+#define MC_CMD_0x118_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
+/* MC_CMD_RX_BALANCING_IN msgrequest */
+#define    MC_CMD_RX_BALANCING_IN_LEN 4
+/* The RX port whose upconverter table will be modified */
+#define       MC_CMD_RX_BALANCING_IN_PORT_OFST 0
+#define       MC_CMD_RX_BALANCING_IN_PORT_LEN 1
+/* The VLAN priority associated to the table index and vFIFO */
+#define       MC_CMD_RX_BALANCING_IN_PRIORITY_OFST 1
+#define       MC_CMD_RX_BALANCING_IN_PRIORITY_LEN 1
+/* The resulting bit of SRC^DST for indexing the table */
+#define       MC_CMD_RX_BALANCING_IN_SRC_DST_OFST 2
+#define       MC_CMD_RX_BALANCING_IN_SRC_DST_LEN 1
+/* The RX engine to which the vFIFO in the table entry will point to */
+#define       MC_CMD_RX_BALANCING_IN_ENG_OFST 3
+#define       MC_CMD_RX_BALANCING_IN_ENG_LEN 1
+
+/* MC_CMD_RX_BALANCING_OUT msgresponse */
+#define    MC_CMD_RX_BALANCING_OUT_LEN 0
+
+
 #endif /* MCDI_PCOL_H */
