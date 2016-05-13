From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] igb: use BIT() macro or unsigned prefix
Date: Fri, 13 May 2016 16:43:44 -0700
Message-ID: <1463183035-31888-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13874 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932118AbcEMXn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:59 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

For bitshifts, we should make use of the BIT macro when possible, and
ensure that other bitshifts are marked as unsigned. This helps prevent
signed bitshift errors, and ensures similar style.

Make use of GENMASK and the unsigned postfix where BIT() isn't
appropriate.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   |   8 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h   |  30 +++----
 drivers/net/ethernet/intel/igb/e1000_defines.h | 108 ++++++++++++-------------
 drivers/net/ethernet/intel/igb/e1000_mac.c     |  10 +--
 drivers/net/ethernet/intel/igb/e1000_mbx.c     |   4 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c     |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h     |   6 +-
 drivers/net/ethernet/intel/igb/igb.h           |  32 ++++----
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  18 ++---
 drivers/net/ethernet/intel/igb/igb_main.c      |  48 +++++------
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   6 +-
 11 files changed, 136 insertions(+), 136 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index a23aa67..a61447f 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -361,7 +361,7 @@ static s32 igb_init_nvm_params_82575(struct e1000_hw *hw)
 	if (size > 15)
 		size = 15;
 
-	nvm->word_size = 1 << size;
+	nvm->word_size = BIT(size);
 	nvm->opcode_bits = 8;
 	nvm->delay_usec = 1;
 
@@ -380,7 +380,7 @@ static s32 igb_init_nvm_params_82575(struct e1000_hw *hw)
 				    16 : 8;
 		break;
 	}
-	if (nvm->word_size == (1 << 15))
+	if (nvm->word_size == BIT(15))
 		nvm->page_size = 128;
 
 	nvm->type = e1000_nvm_eeprom_spi;
@@ -391,7 +391,7 @@ static s32 igb_init_nvm_params_82575(struct e1000_hw *hw)
 	nvm->ops.write = igb_write_nvm_spi;
 	nvm->ops.validate = igb_validate_nvm_checksum;
 	nvm->ops.update = igb_update_nvm_checksum;
-	if (nvm->word_size < (1 << 15))
+	if (nvm->word_size < BIT(15))
 		nvm->ops.read = igb_read_nvm_eerd;
 	else
 		nvm->ops.read = igb_read_nvm_spi;
@@ -2107,7 +2107,7 @@ void igb_vmdq_set_anti_spoofing_pf(struct e1000_hw *hw, bool enable, int pf)
 		/* The PF can spoof - it has to in order to
 		 * support emulation mode NICs
 		 */
-		reg_val ^= (1 << pf | 1 << (pf + MAX_NUM_VFS));
+		reg_val ^= (BIT(pf) | BIT(pf + MAX_NUM_VFS));
 	} else {
 		reg_val &= ~(E1000_DTXSWC_MAC_SPOOF_MASK |
 			     E1000_DTXSWC_VLAN_SPOOF_MASK);
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index de8805a..199ff98 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -168,16 +168,16 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_CTRL_DCA_MODE_CB2     0x02 /* DCA Mode CB2 */
 
 #define E1000_DCA_RXCTRL_CPUID_MASK 0x0000001F /* Rx CPUID Mask */
-#define E1000_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
-#define E1000_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
-#define E1000_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
-#define E1000_DCA_RXCTRL_DESC_RRO_EN (1 << 9) /* DCA Rx rd Desc Relax Order */
+#define E1000_DCA_RXCTRL_DESC_DCA_EN BIT(5) /* DCA Rx Desc enable */
+#define E1000_DCA_RXCTRL_HEAD_DCA_EN BIT(6) /* DCA Rx Desc header enable */
+#define E1000_DCA_RXCTRL_DATA_DCA_EN BIT(7) /* DCA Rx Desc payload enable */
+#define E1000_DCA_RXCTRL_DESC_RRO_EN BIT(9) /* DCA Rx rd Desc Relax Order */
 
 #define E1000_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
-#define E1000_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
-#define E1000_DCA_TXCTRL_DESC_RRO_EN (1 << 9) /* Tx rd Desc Relax Order */
-#define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
-#define E1000_DCA_TXCTRL_DATA_RRO_EN (1 << 13) /* Tx rd data Relax Order */
+#define E1000_DCA_TXCTRL_DESC_DCA_EN BIT(5) /* DCA Tx Desc enable */
+#define E1000_DCA_TXCTRL_DESC_RRO_EN BIT(9) /* Tx rd Desc Relax Order */
+#define E1000_DCA_TXCTRL_TX_WB_RO_EN BIT(11) /* Tx Desc writeback RO bit */
+#define E1000_DCA_TXCTRL_DATA_RRO_EN BIT(13) /* Tx rd data Relax Order */
 
 /* Additional DCA related definitions, note change in position of CPUID */
 #define E1000_DCA_TXCTRL_CPUID_MASK_82576 0xFF000000 /* Tx CPUID Mask */
@@ -186,8 +186,8 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DCA_RXCTRL_CPUID_SHIFT 24 /* Rx CPUID now in the last byte */
 
 /* ETQF register bit definitions */
-#define E1000_ETQF_FILTER_ENABLE   (1 << 26)
-#define E1000_ETQF_1588            (1 << 30)
+#define E1000_ETQF_FILTER_ENABLE   BIT(26)
+#define E1000_ETQF_1588            BIT(30)
 
 /* FTQF register bit definitions */
 #define E1000_FTQF_VF_BP               0x00008000
@@ -203,16 +203,16 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DTXSWC_VLAN_SPOOF_MASK  0x0000FF00 /* Per VF VLAN spoof control */
 #define E1000_DTXSWC_LLE_MASK         0x00FF0000 /* Per VF Local LB enables */
 #define E1000_DTXSWC_VLAN_SPOOF_SHIFT 8
-#define E1000_DTXSWC_VMDQ_LOOPBACK_EN (1 << 31)  /* global VF LB enable */
+#define E1000_DTXSWC_VMDQ_LOOPBACK_EN BIT(31)  /* global VF LB enable */
 
 /* Easy defines for setting default pool, would normally be left a zero */
 #define E1000_VT_CTL_DEFAULT_POOL_SHIFT 7
 #define E1000_VT_CTL_DEFAULT_POOL_MASK  (0x7 << E1000_VT_CTL_DEFAULT_POOL_SHIFT)
 
 /* Other useful VMD_CTL register defines */
-#define E1000_VT_CTL_IGNORE_MAC         (1 << 28)
-#define E1000_VT_CTL_DISABLE_DEF_POOL   (1 << 29)
-#define E1000_VT_CTL_VM_REPL_EN         (1 << 30)
+#define E1000_VT_CTL_IGNORE_MAC         BIT(28)
+#define E1000_VT_CTL_DISABLE_DEF_POOL   BIT(29)
+#define E1000_VT_CTL_VM_REPL_EN         BIT(30)
 
 /* Per VM Offload register setup */
 #define E1000_VMOLR_RLPML_MASK 0x00003FFF /* Long Packet Maximum Length mask */
@@ -252,7 +252,7 @@ struct e1000_adv_tx_context_desc {
 #define E1000_DTXCTL_MDP_EN     0x0020
 #define E1000_DTXCTL_SPOOF_INT  0x0040
 
-#define E1000_EEPROM_PCS_AUTONEG_DISABLE_BIT	(1 << 14)
+#define E1000_EEPROM_PCS_AUTONEG_DISABLE_BIT	BIT(14)
 
 #define ALL_QUEUES   0xFFFF
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index e9f23ee..2997c44 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -530,65 +530,65 @@
 
 /* Time Sync Interrupt Cause/Mask Register Bits */
 
-#define TSINTR_SYS_WRAP  (1 << 0) /* SYSTIM Wrap around. */
-#define TSINTR_TXTS      (1 << 1) /* Transmit Timestamp. */
-#define TSINTR_RXTS      (1 << 2) /* Receive Timestamp. */
-#define TSINTR_TT0       (1 << 3) /* Target Time 0 Trigger. */
-#define TSINTR_TT1       (1 << 4) /* Target Time 1 Trigger. */
-#define TSINTR_AUTT0     (1 << 5) /* Auxiliary Timestamp 0 Taken. */
-#define TSINTR_AUTT1     (1 << 6) /* Auxiliary Timestamp 1 Taken. */
-#define TSINTR_TADJ      (1 << 7) /* Time Adjust Done. */
+#define TSINTR_SYS_WRAP  BIT(0) /* SYSTIM Wrap around. */
+#define TSINTR_TXTS      BIT(1) /* Transmit Timestamp. */
+#define TSINTR_RXTS      BIT(2) /* Receive Timestamp. */
+#define TSINTR_TT0       BIT(3) /* Target Time 0 Trigger. */
+#define TSINTR_TT1       BIT(4) /* Target Time 1 Trigger. */
+#define TSINTR_AUTT0     BIT(5) /* Auxiliary Timestamp 0 Taken. */
+#define TSINTR_AUTT1     BIT(6) /* Auxiliary Timestamp 1 Taken. */
+#define TSINTR_TADJ      BIT(7) /* Time Adjust Done. */
 
 #define TSYNC_INTERRUPTS TSINTR_TXTS
 #define E1000_TSICR_TXTS TSINTR_TXTS
 
 /* TSAUXC Configuration Bits */
-#define TSAUXC_EN_TT0    (1 << 0)  /* Enable target time 0. */
-#define TSAUXC_EN_TT1    (1 << 1)  /* Enable target time 1. */
-#define TSAUXC_EN_CLK0   (1 << 2)  /* Enable Configurable Frequency Clock 0. */
-#define TSAUXC_SAMP_AUT0 (1 << 3)  /* Latch SYSTIML/H into AUXSTMPL/0. */
-#define TSAUXC_ST0       (1 << 4)  /* Start Clock 0 Toggle on Target Time 0. */
-#define TSAUXC_EN_CLK1   (1 << 5)  /* Enable Configurable Frequency Clock 1. */
-#define TSAUXC_SAMP_AUT1 (1 << 6)  /* Latch SYSTIML/H into AUXSTMPL/1. */
-#define TSAUXC_ST1       (1 << 7)  /* Start Clock 1 Toggle on Target Time 1. */
-#define TSAUXC_EN_TS0    (1 << 8)  /* Enable hardware timestamp 0. */
-#define TSAUXC_AUTT0     (1 << 9)  /* Auxiliary Timestamp Taken. */
-#define TSAUXC_EN_TS1    (1 << 10) /* Enable hardware timestamp 0. */
-#define TSAUXC_AUTT1     (1 << 11) /* Auxiliary Timestamp Taken. */
-#define TSAUXC_PLSG      (1 << 17) /* Generate a pulse. */
-#define TSAUXC_DISABLE   (1 << 31) /* Disable SYSTIM Count Operation. */
+#define TSAUXC_EN_TT0    BIT(0)  /* Enable target time 0. */
+#define TSAUXC_EN_TT1    BIT(1)  /* Enable target time 1. */
+#define TSAUXC_EN_CLK0   BIT(2)  /* Enable Configurable Frequency Clock 0. */
+#define TSAUXC_SAMP_AUT0 BIT(3)  /* Latch SYSTIML/H into AUXSTMPL/0. */
+#define TSAUXC_ST0       BIT(4)  /* Start Clock 0 Toggle on Target Time 0. */
+#define TSAUXC_EN_CLK1   BIT(5)  /* Enable Configurable Frequency Clock 1. */
+#define TSAUXC_SAMP_AUT1 BIT(6)  /* Latch SYSTIML/H into AUXSTMPL/1. */
+#define TSAUXC_ST1       BIT(7)  /* Start Clock 1 Toggle on Target Time 1. */
+#define TSAUXC_EN_TS0    BIT(8)  /* Enable hardware timestamp 0. */
+#define TSAUXC_AUTT0     BIT(9)  /* Auxiliary Timestamp Taken. */
+#define TSAUXC_EN_TS1    BIT(10) /* Enable hardware timestamp 0. */
+#define TSAUXC_AUTT1     BIT(11) /* Auxiliary Timestamp Taken. */
+#define TSAUXC_PLSG      BIT(17) /* Generate a pulse. */
+#define TSAUXC_DISABLE   BIT(31) /* Disable SYSTIM Count Operation. */
 
 /* SDP Configuration Bits */
-#define AUX0_SEL_SDP0    (0 << 0)  /* Assign SDP0 to auxiliary time stamp 0. */
-#define AUX0_SEL_SDP1    (1 << 0)  /* Assign SDP1 to auxiliary time stamp 0. */
-#define AUX0_SEL_SDP2    (2 << 0)  /* Assign SDP2 to auxiliary time stamp 0. */
-#define AUX0_SEL_SDP3    (3 << 0)  /* Assign SDP3 to auxiliary time stamp 0. */
-#define AUX0_TS_SDP_EN   (1 << 2)  /* Enable auxiliary time stamp trigger 0. */
-#define AUX1_SEL_SDP0    (0 << 3)  /* Assign SDP0 to auxiliary time stamp 1. */
-#define AUX1_SEL_SDP1    (1 << 3)  /* Assign SDP1 to auxiliary time stamp 1. */
-#define AUX1_SEL_SDP2    (2 << 3)  /* Assign SDP2 to auxiliary time stamp 1. */
-#define AUX1_SEL_SDP3    (3 << 3)  /* Assign SDP3 to auxiliary time stamp 1. */
-#define AUX1_TS_SDP_EN   (1 << 5)  /* Enable auxiliary time stamp trigger 1. */
-#define TS_SDP0_SEL_TT0  (0 << 6)  /* Target time 0 is output on SDP0. */
-#define TS_SDP0_SEL_TT1  (1 << 6)  /* Target time 1 is output on SDP0. */
-#define TS_SDP0_SEL_FC0  (2 << 6)  /* Freq clock  0 is output on SDP0. */
-#define TS_SDP0_SEL_FC1  (3 << 6)  /* Freq clock  1 is output on SDP0. */
-#define TS_SDP0_EN       (1 << 8)  /* SDP0 is assigned to Tsync. */
-#define TS_SDP1_SEL_TT0  (0 << 9)  /* Target time 0 is output on SDP1. */
-#define TS_SDP1_SEL_TT1  (1 << 9)  /* Target time 1 is output on SDP1. */
-#define TS_SDP1_SEL_FC0  (2 << 9)  /* Freq clock  0 is output on SDP1. */
-#define TS_SDP1_SEL_FC1  (3 << 9)  /* Freq clock  1 is output on SDP1. */
-#define TS_SDP1_EN       (1 << 11) /* SDP1 is assigned to Tsync. */
-#define TS_SDP2_SEL_TT0  (0 << 12) /* Target time 0 is output on SDP2. */
-#define TS_SDP2_SEL_TT1  (1 << 12) /* Target time 1 is output on SDP2. */
-#define TS_SDP2_SEL_FC0  (2 << 12) /* Freq clock  0 is output on SDP2. */
-#define TS_SDP2_SEL_FC1  (3 << 12) /* Freq clock  1 is output on SDP2. */
-#define TS_SDP2_EN       (1 << 14) /* SDP2 is assigned to Tsync. */
-#define TS_SDP3_SEL_TT0  (0 << 15) /* Target time 0 is output on SDP3. */
-#define TS_SDP3_SEL_TT1  (1 << 15) /* Target time 1 is output on SDP3. */
-#define TS_SDP3_SEL_FC0  (2 << 15) /* Freq clock  0 is output on SDP3. */
-#define TS_SDP3_SEL_FC1  (3 << 15) /* Freq clock  1 is output on SDP3. */
-#define TS_SDP3_EN       (1 << 17) /* SDP3 is assigned to Tsync. */
+#define AUX0_SEL_SDP0    (0u << 0)  /* Assign SDP0 to auxiliary time stamp 0. */
+#define AUX0_SEL_SDP1    (1u << 0)  /* Assign SDP1 to auxiliary time stamp 0. */
+#define AUX0_SEL_SDP2    (2u << 0)  /* Assign SDP2 to auxiliary time stamp 0. */
+#define AUX0_SEL_SDP3    (3u << 0)  /* Assign SDP3 to auxiliary time stamp 0. */
+#define AUX0_TS_SDP_EN   (1u << 2)  /* Enable auxiliary time stamp trigger 0. */
+#define AUX1_SEL_SDP0    (0u << 3)  /* Assign SDP0 to auxiliary time stamp 1. */
+#define AUX1_SEL_SDP1    (1u << 3)  /* Assign SDP1 to auxiliary time stamp 1. */
+#define AUX1_SEL_SDP2    (2u << 3)  /* Assign SDP2 to auxiliary time stamp 1. */
+#define AUX1_SEL_SDP3    (3u << 3)  /* Assign SDP3 to auxiliary time stamp 1. */
+#define AUX1_TS_SDP_EN   (1u << 5)  /* Enable auxiliary time stamp trigger 1. */
+#define TS_SDP0_SEL_TT0  (0u << 6)  /* Target time 0 is output on SDP0. */
+#define TS_SDP0_SEL_TT1  (1u << 6)  /* Target time 1 is output on SDP0. */
+#define TS_SDP0_SEL_FC0  (2u << 6)  /* Freq clock  0 is output on SDP0. */
+#define TS_SDP0_SEL_FC1  (3u << 6)  /* Freq clock  1 is output on SDP0. */
+#define TS_SDP0_EN       (1u << 8)  /* SDP0 is assigned to Tsync. */
+#define TS_SDP1_SEL_TT0  (0u << 9)  /* Target time 0 is output on SDP1. */
+#define TS_SDP1_SEL_TT1  (1u << 9)  /* Target time 1 is output on SDP1. */
+#define TS_SDP1_SEL_FC0  (2u << 9)  /* Freq clock  0 is output on SDP1. */
+#define TS_SDP1_SEL_FC1  (3u << 9)  /* Freq clock  1 is output on SDP1. */
+#define TS_SDP1_EN       (1u << 11) /* SDP1 is assigned to Tsync. */
+#define TS_SDP2_SEL_TT0  (0u << 12) /* Target time 0 is output on SDP2. */
+#define TS_SDP2_SEL_TT1  (1u << 12) /* Target time 1 is output on SDP2. */
+#define TS_SDP2_SEL_FC0  (2u << 12) /* Freq clock  0 is output on SDP2. */
+#define TS_SDP2_SEL_FC1  (3u << 12) /* Freq clock  1 is output on SDP2. */
+#define TS_SDP2_EN       (1u << 14) /* SDP2 is assigned to Tsync. */
+#define TS_SDP3_SEL_TT0  (0u << 15) /* Target time 0 is output on SDP3. */
+#define TS_SDP3_SEL_TT1  (1u << 15) /* Target time 1 is output on SDP3. */
+#define TS_SDP3_SEL_FC0  (2u << 15) /* Freq clock  0 is output on SDP3. */
+#define TS_SDP3_SEL_FC1  (3u << 15) /* Freq clock  1 is output on SDP3. */
+#define TS_SDP3_EN       (1u << 17) /* SDP3 is assigned to Tsync. */
 
 #define E1000_MDICNFG_EXT_MDIO    0x80000000      /* MDI ext/int destination */
 #define E1000_MDICNFG_COM_MDIO    0x40000000      /* MDI shared w/ lan 0 */
@@ -997,8 +997,8 @@
 #define E1000_M88E1543_FIBER_CTRL	0x0
 #define E1000_EEE_ADV_DEV_I354		7
 #define E1000_EEE_ADV_ADDR_I354		60
-#define E1000_EEE_ADV_100_SUPPORTED	(1 << 1)   /* 100BaseTx EEE Supported */
-#define E1000_EEE_ADV_1000_SUPPORTED	(1 << 2)   /* 1000BaseT EEE Supported */
+#define E1000_EEE_ADV_100_SUPPORTED	BIT(1)   /* 100BaseTx EEE Supported */
+#define E1000_EEE_ADV_1000_SUPPORTED	BIT(2)   /* 1000BaseT EEE Supported */
 #define E1000_PCS_STATUS_DEV_I354	3
 #define E1000_PCS_STATUS_ADDR_I354	1
 #define E1000_PCS_STATUS_TX_LPI_IND	0x0200     /* Tx in LPI state */
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 07cf4fe..5010e22 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -212,7 +212,7 @@ s32 igb_vfta_set(struct e1000_hw *hw, u32 vlan, u32 vind,
 	 *    bits[4-0]:  which bit in the register
 	 */
 	regidx = vlan / 32;
-	vfta_delta = 1 << (vlan % 32);
+	vfta_delta = BIT(vlan % 32);
 	vfta = adapter->shadow_vfta[regidx];
 
 	/* vfta_delta represents the difference between the current value
@@ -243,12 +243,12 @@ s32 igb_vfta_set(struct e1000_hw *hw, u32 vlan, u32 vind,
 	bits = rd32(E1000_VLVF(vlvf_index));
 
 	/* set the pool bit */
-	bits |= 1 << (E1000_VLVF_POOLSEL_SHIFT + vind);
+	bits |= BIT(E1000_VLVF_POOLSEL_SHIFT + vind);
 	if (vlan_on)
 		goto vlvf_update;
 
 	/* clear the pool bit */
-	bits ^= 1 << (E1000_VLVF_POOLSEL_SHIFT + vind);
+	bits ^= BIT(E1000_VLVF_POOLSEL_SHIFT + vind);
 
 	if (!(bits & E1000_VLVF_POOLSEL_MASK)) {
 		/* Clear VFTA first, then disable VLVF.  Otherwise
@@ -427,7 +427,7 @@ void igb_mta_set(struct e1000_hw *hw, u32 hash_value)
 
 	mta = array_rd32(E1000_MTA, hash_reg);
 
-	mta |= (1 << hash_bit);
+	mta |= BIT(hash_bit);
 
 	array_wr32(E1000_MTA, hash_reg, mta);
 	wrfl();
@@ -527,7 +527,7 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
 		hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
 		hash_bit = hash_value & 0x1F;
 
-		hw->mac.mta_shadow[hash_reg] |= (1 << hash_bit);
+		hw->mac.mta_shadow[hash_reg] |= BIT(hash_bit);
 		mc_addr_list += (ETH_ALEN);
 	}
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.c b/drivers/net/ethernet/intel/igb/e1000_mbx.c
index 10f5c9e..00e263f 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.c
@@ -302,9 +302,9 @@ static s32 igb_check_for_rst_pf(struct e1000_hw *hw, u16 vf_number)
 	u32 vflre = rd32(E1000_VFLRE);
 	s32 ret_val = -E1000_ERR_MBX;
 
-	if (vflre & (1 << vf_number)) {
+	if (vflre & BIT(vf_number)) {
 		ret_val = 0;
-		wr32(E1000_VFLRE, (1 << vf_number));
+		wr32(E1000_VFLRE, BIT(vf_number));
 		hw->mbx.stats.rsts++;
 	}
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
index e8280d0..3582c5c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.c
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.c
@@ -72,7 +72,7 @@ static void igb_shift_out_eec_bits(struct e1000_hw *hw, u16 data, u16 count)
 	u32 eecd = rd32(E1000_EECD);
 	u32 mask;
 
-	mask = 0x01 << (count - 1);
+	mask = 1u << (count - 1);
 	if (nvm->type == e1000_nvm_eeprom_spi)
 		eecd |= E1000_EECD_DO;
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 969a6dd..9b622b3 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -91,10 +91,10 @@ s32  igb_check_polarity_m88(struct e1000_hw *hw);
 
 #define I82580_ADDR_REG                   16
 #define I82580_CFG_REG                    22
-#define I82580_CFG_ASSERT_CRS_ON_TX       (1 << 15)
-#define I82580_CFG_ENABLE_DOWNSHIFT       (3 << 10) /* auto downshift 100/10 */
+#define I82580_CFG_ASSERT_CRS_ON_TX       BIT(15)
+#define I82580_CFG_ENABLE_DOWNSHIFT       (3u << 10) /* auto downshift 100/10 */
 #define I82580_CTRL_REG                   23
-#define I82580_CTRL_DOWNSHIFT_MASK        (7 << 10)
+#define I82580_CTRL_DOWNSHIFT_MASK        (7u << 10)
 
 /* 82580 specific PHY registers */
 #define I82580_PHY_CTRL_2            18
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9413fa6..7a7bc31 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -169,7 +169,7 @@ enum igb_tx_flags {
  * maintain a power of two alignment we have to limit ourselves to 32K.
  */
 #define IGB_MAX_TXD_PWR	15
-#define IGB_MAX_DATA_PER_TXD	(1 << IGB_MAX_TXD_PWR)
+#define IGB_MAX_DATA_PER_TXD	(1u << IGB_MAX_TXD_PWR)
 
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IGB_MAX_DATA_PER_TXD)
@@ -466,21 +466,21 @@ struct igb_adapter {
 	u16 eee_advert;
 };
 
-#define IGB_FLAG_HAS_MSI		(1 << 0)
-#define IGB_FLAG_DCA_ENABLED		(1 << 1)
-#define IGB_FLAG_QUAD_PORT_A		(1 << 2)
-#define IGB_FLAG_QUEUE_PAIRS		(1 << 3)
-#define IGB_FLAG_DMAC			(1 << 4)
-#define IGB_FLAG_PTP			(1 << 5)
-#define IGB_FLAG_RSS_FIELD_IPV4_UDP	(1 << 6)
-#define IGB_FLAG_RSS_FIELD_IPV6_UDP	(1 << 7)
-#define IGB_FLAG_WOL_SUPPORTED		(1 << 8)
-#define IGB_FLAG_NEED_LINK_UPDATE	(1 << 9)
-#define IGB_FLAG_MEDIA_RESET		(1 << 10)
-#define IGB_FLAG_MAS_CAPABLE		(1 << 11)
-#define IGB_FLAG_MAS_ENABLE		(1 << 12)
-#define IGB_FLAG_HAS_MSIX		(1 << 13)
-#define IGB_FLAG_EEE			(1 << 14)
+#define IGB_FLAG_HAS_MSI		BIT(0)
+#define IGB_FLAG_DCA_ENABLED		BIT(1)
+#define IGB_FLAG_QUAD_PORT_A		BIT(2)
+#define IGB_FLAG_QUEUE_PAIRS		BIT(3)
+#define IGB_FLAG_DMAC			BIT(4)
+#define IGB_FLAG_PTP			BIT(5)
+#define IGB_FLAG_RSS_FIELD_IPV4_UDP	BIT(6)
+#define IGB_FLAG_RSS_FIELD_IPV6_UDP	BIT(7)
+#define IGB_FLAG_WOL_SUPPORTED		BIT(8)
+#define IGB_FLAG_NEED_LINK_UPDATE	BIT(9)
+#define IGB_FLAG_MEDIA_RESET		BIT(10)
+#define IGB_FLAG_MAS_CAPABLE		BIT(11)
+#define IGB_FLAG_MAS_ENABLE		BIT(12)
+#define IGB_FLAG_HAS_MSIX		BIT(13)
+#define IGB_FLAG_EEE			BIT(14)
 #define IGB_FLAG_VLAN_PROMISC		BIT(15)
 
 /* Media Auto Sense */
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index bb4d6cd..64e91c5 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -466,7 +466,7 @@ static void igb_get_regs(struct net_device *netdev,
 
 	memset(p, 0, IGB_REGS_LEN * sizeof(u32));
 
-	regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
+	regs->version = (1u << 24) | (hw->revision_id << 16) | hw->device_id;
 
 	/* General Registers */
 	regs_buff[0] = rd32(E1000_CTRL);
@@ -1448,7 +1448,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	/* Test each interrupt */
 	for (; i < 31; i++) {
 		/* Interrupt to test */
-		mask = 1 << i;
+		mask = BIT(i);
 
 		if (!(mask & ics_mask))
 			continue;
@@ -2411,19 +2411,19 @@ static int igb_get_ts_info(struct net_device *dev,
 			SOF_TIMESTAMPING_RAW_HARDWARE;
 
 		info->tx_types =
-			(1 << HWTSTAMP_TX_OFF) |
-			(1 << HWTSTAMP_TX_ON);
+			BIT(HWTSTAMP_TX_OFF) |
+			BIT(HWTSTAMP_TX_ON);
 
-		info->rx_filters = 1 << HWTSTAMP_FILTER_NONE;
+		info->rx_filters = BIT(HWTSTAMP_FILTER_NONE);
 
 		/* 82576 does not support timestamping all packets. */
 		if (adapter->hw.mac.type >= e1000_82580)
-			info->rx_filters |= 1 << HWTSTAMP_FILTER_ALL;
+			info->rx_filters |= BIT(HWTSTAMP_FILTER_ALL);
 		else
 			info->rx_filters |=
-				(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
-				(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
-				(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
+				BIT(HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+				BIT(HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+				BIT(HWTSTAMP_FILTER_PTP_V2_EVENT);
 
 		return 0;
 	default:
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7460bdb..0191c5f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -836,7 +836,7 @@ static void igb_assign_vector(struct igb_q_vector *q_vector, int msix_vector)
 			igb_write_ivar(hw, msix_vector,
 				       tx_queue & 0x7,
 				       ((tx_queue & 0x8) << 1) + 8);
-		q_vector->eims_value = 1 << msix_vector;
+		q_vector->eims_value = BIT(msix_vector);
 		break;
 	case e1000_82580:
 	case e1000_i350:
@@ -857,7 +857,7 @@ static void igb_assign_vector(struct igb_q_vector *q_vector, int msix_vector)
 			igb_write_ivar(hw, msix_vector,
 				       tx_queue >> 1,
 				       ((tx_queue & 0x1) << 4) + 8);
-		q_vector->eims_value = 1 << msix_vector;
+		q_vector->eims_value = BIT(msix_vector);
 		break;
 	default:
 		BUG();
@@ -919,7 +919,7 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 		     E1000_GPIE_NSICR);
 
 		/* enable msix_other interrupt */
-		adapter->eims_other = 1 << vector;
+		adapter->eims_other = BIT(vector);
 		tmp = (vector++ | E1000_IVAR_VALID) << 8;
 
 		wr32(E1000_IVAR_MISC, tmp);
@@ -4064,7 +4064,7 @@ static int igb_vlan_promisc_enable(struct igb_adapter *adapter)
 	for (i = E1000_VLVF_ARRAY_SIZE; --i;) {
 		u32 vlvf = rd32(E1000_VLVF(i));
 
-		vlvf |= 1 << pf_id;
+		vlvf |= BIT(pf_id);
 		wr32(E1000_VLVF(i), vlvf);
 	}
 
@@ -4091,7 +4091,7 @@ static void igb_scrub_vfta(struct igb_adapter *adapter, u32 vfta_offset)
 	/* guarantee that we don't scrub out management VLAN */
 	vid = adapter->mng_vlan_id;
 	if (vid >= vid_start && vid < vid_end)
-		vfta[(vid - vid_start) / 32] |= 1 << (vid % 32);
+		vfta[(vid - vid_start) / 32] |= BIT(vid % 32);
 
 	if (!adapter->vfs_allocated_count)
 		goto set_vfta;
@@ -4110,7 +4110,7 @@ static void igb_scrub_vfta(struct igb_adapter *adapter, u32 vfta_offset)
 
 		if (vlvf & E1000_VLVF_VLANID_ENABLE) {
 			/* record VLAN ID in VFTA */
-			vfta[(vid - vid_start) / 32] |= 1 << (vid % 32);
+			vfta[(vid - vid_start) / 32] |= BIT(vid % 32);
 
 			/* if PF is part of this then continue */
 			if (test_bit(vid, adapter->active_vlans))
@@ -4118,7 +4118,7 @@ static void igb_scrub_vfta(struct igb_adapter *adapter, u32 vfta_offset)
 		}
 
 		/* remove PF from the pool */
-		bits = ~(1 << pf_id);
+		bits = ~BIT(pf_id);
 		bits &= rd32(E1000_VLVF(i));
 		wr32(E1000_VLVF(i), bits);
 	}
@@ -4276,13 +4276,13 @@ static void igb_spoof_check(struct igb_adapter *adapter)
 		return;
 
 	for (j = 0; j < adapter->vfs_allocated_count; j++) {
-		if (adapter->wvbr & (1 << j) ||
-		    adapter->wvbr & (1 << (j + IGB_STAGGERED_QUEUE_OFFSET))) {
+		if (adapter->wvbr & BIT(j) ||
+		    adapter->wvbr & BIT(j + IGB_STAGGERED_QUEUE_OFFSET)) {
 			dev_warn(&adapter->pdev->dev,
 				"Spoof event(s) detected on VF %d\n", j);
 			adapter->wvbr &=
-				~((1 << j) |
-				  (1 << (j + IGB_STAGGERED_QUEUE_OFFSET)));
+				~(BIT(j) |
+				  BIT(j + IGB_STAGGERED_QUEUE_OFFSET));
 		}
 	}
 }
@@ -5963,11 +5963,11 @@ static void igb_clear_vf_vfta(struct igb_adapter *adapter, u32 vf)
 
 	/* create mask for VF and other pools */
 	pool_mask = E1000_VLVF_POOLSEL_MASK;
-	vlvf_mask = 1 << (E1000_VLVF_POOLSEL_SHIFT + vf);
+	vlvf_mask = BIT(E1000_VLVF_POOLSEL_SHIFT + vf);
 
 	/* drop PF from pool bits */
-	pool_mask &= ~(1 << (E1000_VLVF_POOLSEL_SHIFT +
-			     adapter->vfs_allocated_count));
+	pool_mask &= ~BIT(E1000_VLVF_POOLSEL_SHIFT +
+			     adapter->vfs_allocated_count);
 
 	/* Find the vlan filter for this id */
 	for (i = E1000_VLVF_ARRAY_SIZE; i--;) {
@@ -5990,7 +5990,7 @@ static void igb_clear_vf_vfta(struct igb_adapter *adapter, u32 vf)
 			goto update_vlvf;
 
 		vid = vlvf & E1000_VLVF_VLANID_MASK;
-		vfta_mask = 1 << (vid % 32);
+		vfta_mask = BIT(vid % 32);
 
 		/* clear bit from VFTA */
 		vfta = adapter->shadow_vfta[vid / 32];
@@ -6041,13 +6041,13 @@ void igb_update_pf_vlvf(struct igb_adapter *adapter, u32 vid)
 	 * entry other than the PF.
 	 */
 	pf_id = adapter->vfs_allocated_count + E1000_VLVF_POOLSEL_SHIFT;
-	bits = ~(1 << pf_id) & E1000_VLVF_POOLSEL_MASK;
+	bits = ~BIT(pf_id) & E1000_VLVF_POOLSEL_MASK;
 	bits &= rd32(E1000_VLVF(idx));
 
 	/* Disable the filter so this falls into the default pool. */
 	if (!bits) {
 		if (adapter->flags & IGB_FLAG_VLAN_PROMISC)
-			wr32(E1000_VLVF(idx), 1 << pf_id);
+			wr32(E1000_VLVF(idx), BIT(pf_id));
 		else
 			wr32(E1000_VLVF(idx), 0);
 	}
@@ -6231,9 +6231,9 @@ static void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 
 	/* enable transmit and receive for vf */
 	reg = rd32(E1000_VFTE);
-	wr32(E1000_VFTE, reg | (1 << vf));
+	wr32(E1000_VFTE, reg | BIT(vf));
 	reg = rd32(E1000_VFRE);
-	wr32(E1000_VFRE, reg | (1 << vf));
+	wr32(E1000_VFRE, reg | BIT(vf));
 
 	adapter->vf_data[vf].flags |= IGB_VF_FLAG_CTS;
 
@@ -7927,7 +7927,7 @@ static void igb_set_vf_rate_limit(struct e1000_hw *hw, int vf, int tx_rate,
 		/* Calculate the rate factor values to set */
 		rf_int = link_speed / tx_rate;
 		rf_dec = (link_speed - (rf_int * tx_rate));
-		rf_dec = (rf_dec * (1 << E1000_RTTBCNRC_RF_INT_SHIFT)) /
+		rf_dec = (rf_dec * BIT(E1000_RTTBCNRC_RF_INT_SHIFT)) /
 			 tx_rate;
 
 		bcnrc_val = E1000_RTTBCNRC_RS_ENA;
@@ -8017,11 +8017,11 @@ static int igb_ndo_set_vf_spoofchk(struct net_device *netdev, int vf,
 	reg_offset = (hw->mac.type == e1000_82576) ? E1000_DTXSWC : E1000_TXSWC;
 	reg_val = rd32(reg_offset);
 	if (setting)
-		reg_val |= ((1 << vf) |
-			    (1 << (vf + E1000_DTXSWC_VLAN_SPOOF_SHIFT)));
+		reg_val |= (BIT(vf) |
+			    BIT(vf + E1000_DTXSWC_VLAN_SPOOF_SHIFT));
 	else
-		reg_val &= ~((1 << vf) |
-			     (1 << (vf + E1000_DTXSWC_VLAN_SPOOF_SHIFT)));
+		reg_val &= ~(BIT(vf) |
+			     BIT(vf + E1000_DTXSWC_VLAN_SPOOF_SHIFT));
 	wr32(reg_offset, reg_val);
 
 	adapter->vf_data[vf].spoofchk_enabled = setting;
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 22a8a29..fdb6dfd 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -69,9 +69,9 @@
 
 #define IGB_SYSTIM_OVERFLOW_PERIOD	(HZ * 60 * 9)
 #define IGB_PTP_TX_TIMEOUT		(HZ * 15)
-#define INCPERIOD_82576			(1 << E1000_TIMINCA_16NS_SHIFT)
-#define INCVALUE_82576_MASK		((1 << E1000_TIMINCA_16NS_SHIFT) - 1)
-#define INCVALUE_82576			(16 << IGB_82576_TSYNC_SHIFT)
+#define INCPERIOD_82576			BIT(E1000_TIMINCA_16NS_SHIFT)
+#define INCVALUE_82576_MASK		GENMASK(E1000_TIMINCA_16NS_SHIFT - 1, 0)
+#define INCVALUE_82576			(16u << IGB_82576_TSYNC_SHIFT)
 #define IGB_NBITS_82580			40
 
 static void igb_ptp_tx_hwtstamp(struct igb_adapter *adapter);
-- 
2.5.5
