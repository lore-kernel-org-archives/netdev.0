From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 3/4] net: dsa: bcm_sf2: Add CFP registers definitions
Date: Mon, 30 Jan 2017 09:48:42 -0800
Message-ID: <20170130174843.29497-4-f.fainelli@gmail.com>
References: <20170130174843.29497-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33700 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752538AbdA3RzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 12:55:04 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so32064131pgd.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 09:55:04 -0800 (PST)
In-Reply-To: <20170130174843.29497-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Compact Field Processor definitions for the Broadcom Starfighter 2
and compatible versions of the switch.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2_regs.h | 146 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 146 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 6b63c00928ba..26052450091e 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -255,4 +255,150 @@ enum bcm_sf2_reg_offs {
 #define CORE_EEE_EN_CTRL		0x24800
 #define CORE_EEE_LPI_INDICATE		0x24810
 
+#define CORE_CFP_ACC			0x28000
+#define  OP_STR_DONE			(1 << 0)
+#define  OP_SEL_SHIFT			1
+#define  OP_SEL_READ			(1 << OP_SEL_SHIFT)
+#define  OP_SEL_WRITE			(2 << OP_SEL_SHIFT)
+#define  OP_SEL_SEARCH			(4 << OP_SEL_SHIFT)
+#define  OP_SEL_MASK			(7 << OP_SEL_SHIFT)
+#define  CFP_RAM_CLEAR			(1 << 4)
+#define  RAM_SEL_SHIFT			10
+#define  TCAM_SEL			(1 << RAM_SEL_SHIFT)
+#define  ACT_POL_RAM			(2 << RAM_SEL_SHIFT)
+#define  RATE_METER_RAM			(4 << RAM_SEL_SHIFT)
+#define  GREEN_STAT_RAM			(8 << RAM_SEL_SHIFT)
+#define  YELLOW_STAT_RAM		(16 << RAM_SEL_SHIFT)
+#define  RED_STAT_RAM			(24 << RAM_SEL_SHIFT)
+#define  RAM_SEL_MASK			(0x1f << RAM_SEL_SHIFT)
+#define  TCAM_RESET			(1 << 15)
+#define  XCESS_ADDR_SHIFT		16
+#define  XCESS_ADDR_MASK		0xff
+#define  SEARCH_STS			(1 << 27)
+#define  RD_STS_SHIFT			28
+#define  RD_STS_TCAM			(1 << RD_STS_SHIFT)
+#define  RD_STS_ACT_POL_RAM		(2 << RD_STS_SHIFT)
+#define  RD_STS_RATE_METER_RAM		(4 << RD_STS_SHIFT)
+#define  RD_STS_STAT_RAM		(8 << RD_STS_SHIFT)
+
+#define CORE_CFP_RATE_METER_GLOBAL_CTL	0x28010
+
+#define CORE_CFP_DATA_PORT_0		0x28040
+#define CORE_CFP_DATA_PORT(x)		(CORE_CFP_DATA_PORT_0 + \
+					(x) * 0x10)
+
+/* UDF_DATA7 */
+#define L3_FRAMING_SHIFT		24
+#define L3_FRAMING_MASK			(0x3 << L3_FRAMING_SHIFT)
+#define IPPROTO_SHIFT			8
+#define IPPROTO_MASK			(0xff << IPPROTO_SHIFT)
+#define IP_FRAG				(1 << 7)
+
+/* UDF_DATA0 */
+#define  SLICE_VALID			3
+#define  SLICE_NUM_SHIFT		2
+#define  SLICE_NUM(x)			((x) << SLICE_NUM_SHIFT)
+
+#define CORE_CFP_MASK_PORT_0		0x280c0
+
+#define CORE_CFP_MASK_PORT(x)		(CORE_CFP_MASK_PORT_0 + \
+					(x) * 0x10)
+
+#define CORE_ACT_POL_DATA0		0x28140
+#define  VLAN_BYP			(1 << 0)
+#define  EAP_BYP			(1 << 1)
+#define  STP_BYP			(1 << 2)
+#define  REASON_CODE_SHIFT		3
+#define  REASON_CODE_MASK		0x3f
+#define  LOOP_BK_EN			(1 << 9)
+#define  NEW_TC_SHIFT			10
+#define  NEW_TC_MASK			0x7
+#define  CHANGE_TC			(1 << 13)
+#define  DST_MAP_IB_SHIFT		14
+#define  DST_MAP_IB_MASK		0x1ff
+#define  CHANGE_FWRD_MAP_IB_SHIFT	24
+#define  CHANGE_FWRD_MAP_IB_MASK	0x3
+#define  CHANGE_FWRD_MAP_IB_NO_DEST	(0 << CHANGE_FWRD_MAP_IB_SHIFT)
+#define  CHANGE_FWRD_MAP_IB_REM_ARL	(1 << CHANGE_FWRD_MAP_IB_SHIFT)
+#define  CHANGE_FWRD_MAP_IB_REP_ARL	(2 << CHANGE_FWRD_MAP_IB_SHIFT)
+#define  CHANGE_FWRD_MAP_IB_ADD_DST	(3 << CHANGE_FWRD_MAP_IB_SHIFT)
+#define  NEW_DSCP_IB_SHIFT		26
+#define  NEW_DSCP_IB_MASK		0x3f
+
+#define CORE_ACT_POL_DATA1		0x28150
+#define  CHANGE_DSCP_IB			(1 << 0)
+#define  DST_MAP_OB_SHIFT		1
+#define  DST_MAP_OB_MASK		0x3ff
+#define  CHANGE_FWRD_MAP_OB_SHIT	11
+#define  CHANGE_FWRD_MAP_OB_MASK	0x3
+#define  NEW_DSCP_OB_SHIFT		13
+#define  NEW_DSCP_OB_MASK		0x3f
+#define  CHANGE_DSCP_OB			(1 << 19)
+#define  CHAIN_ID_SHIFT			20
+#define  CHAIN_ID_MASK			0xff
+#define  CHANGE_COLOR			(1 << 28)
+#define  NEW_COLOR_SHIFT		29
+#define  NEW_COLOR_MASK			0x3
+#define  NEW_COLOR_GREEN		(0 << NEW_COLOR_SHIFT)
+#define  NEW_COLOR_YELLOW		(1 << NEW_COLOR_SHIFT)
+#define  NEW_COLOR_RED			(2 << NEW_COLOR_SHIFT)
+#define  RED_DEFAULT			(1 << 31)
+
+#define CORE_ACT_POL_DATA2		0x28160
+#define  MAC_LIMIT_BYPASS		(1 << 0)
+#define  CHANGE_TC_O			(1 << 1)
+#define  NEW_TC_O_SHIFT			2
+#define  NEW_TC_O_MASK			0x7
+#define  SPCP_RMK_DISABLE		(1 << 5)
+#define  CPCP_RMK_DISABLE		(1 << 6)
+#define  DEI_RMK_DISABLE		(1 << 7)
+
+#define CORE_RATE_METER0		0x28180
+#define  COLOR_MODE			(1 << 0)
+#define  POLICER_ACTION			(1 << 1)
+#define  COUPLING_FLAG			(1 << 2)
+#define  POLICER_MODE_SHIFT		3
+#define  POLICER_MODE_MASK		0x3
+#define  POLICER_MODE_RFC2698		(0 << POLICER_MODE_SHIFT)
+#define  POLICER_MODE_RFC4115		(1 << POLICER_MODE_SHIFT)
+#define  POLICER_MODE_MEF		(2 << POLICER_MODE_SHIFT)
+#define  POLICER_MODE_DISABLE		(3 << POLICER_MODE_SHIFT)
+
+#define CORE_RATE_METER1		0x28190
+#define  EIR_TK_BKT_MASK		0x7fffff
+
+#define CORE_RATE_METER2		0x281a0
+#define  EIR_BKT_SIZE_MASK		0xfffff
+
+#define CORE_RATE_METER3		0x281b0
+#define  EIR_REF_CNT_MASK		0x7ffff
+
+#define CORE_RATE_METER4		0x281c0
+#define  CIR_TK_BKT_MASK		0x7fffff
+
+#define CORE_RATE_METER5		0x281d0
+#define  CIR_BKT_SIZE_MASK		0xfffff
+
+#define CORE_RATE_METER6		0x281e0
+#define  CIR_REF_CNT_MASK		0x7ffff
+
+#define CORE_CFP_CTL_REG		0x28400
+#define  CFP_EN_MAP_MASK		0x1ff
+
+/* IPv4 slices, 3 of them */
+#define CORE_UDF_0_A_0_8_PORT_0		0x28440
+#define  CFG_UDF_OFFSET_MASK		0x1f
+#define  CFG_UDF_OFFSET_BASE_SHIFT	5
+#define  CFG_UDF_SOF			(0 << CFG_UDF_OFFSET_BASE_SHIFT)
+#define  CFG_UDF_EOL2			(2 << CFG_UDF_OFFSET_BASE_SHIFT)
+#define  CFG_UDF_EOL3			(3 << CFG_UDF_OFFSET_BASE_SHIFT)
+
+/* Number of slices for IPv4, IPv6 and non-IP */
+#define UDF_NUM_SLICES			9
+
+/* Spacing between different slices */
+#define UDF_SLICE_OFFSET		0x40
+
+#define CFP_NUM_RULES			256
+
 #endif /* __BCM_SF2_REGS_H */
-- 
2.9.3
