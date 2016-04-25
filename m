From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbevf: make use of BIT() macro to avoid shift of signed values
Date: Mon, 25 Apr 2016 05:44:26 -0700
Message-ID: <1461588269-128728-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932421AbcDYMog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:36 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Also cleanup a case where we're bit shifting a value into place, and use
an unsigned constant. Make use of the unsigned postfix in places where
BIT() macro is not appropriate.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/defines.h      | 24 +++++++++++------------
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  3 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  8 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 18 ++++++++---------
 4 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
index 5843458..74901f7 100644
--- a/drivers/net/ethernet/intel/ixgbevf/defines.h
+++ b/drivers/net/ethernet/intel/ixgbevf/defines.h
@@ -74,7 +74,7 @@ typedef u32 ixgbe_link_speed;
 #define IXGBE_RXDCTL_RLPML_EN	0x00008000
 
 /* DCA Control */
-#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
+#define IXGBE_DCA_TXCTRL_TX_WB_RO_EN BIT(11) /* Tx Desc writeback RO bit */
 
 /* PSRTYPE bit definitions */
 #define IXGBE_PSRTYPE_TCPHDR	0x00000010
@@ -296,16 +296,16 @@ struct ixgbe_adv_tx_context_desc {
 #define IXGBE_TXDCTL_SWFLSH		0x04000000 /* Tx Desc. wr-bk flushing */
 #define IXGBE_TXDCTL_WTHRESH_SHIFT	16	   /* shift to WTHRESH bits */
 
-#define IXGBE_DCA_RXCTRL_DESC_DCA_EN	(1 << 5)  /* Rx Desc enable */
-#define IXGBE_DCA_RXCTRL_HEAD_DCA_EN	(1 << 6)  /* Rx Desc header ena */
-#define IXGBE_DCA_RXCTRL_DATA_DCA_EN	(1 << 7)  /* Rx Desc payload ena */
-#define IXGBE_DCA_RXCTRL_DESC_RRO_EN	(1 << 9)  /* Rx rd Desc Relax Order */
-#define IXGBE_DCA_RXCTRL_DATA_WRO_EN	(1 << 13) /* Rx wr data Relax Order */
-#define IXGBE_DCA_RXCTRL_HEAD_WRO_EN	(1 << 15) /* Rx wr header RO */
-
-#define IXGBE_DCA_TXCTRL_DESC_DCA_EN	(1 << 5)  /* DCA Tx Desc enable */
-#define IXGBE_DCA_TXCTRL_DESC_RRO_EN	(1 << 9)  /* Tx rd Desc Relax Order */
-#define IXGBE_DCA_TXCTRL_DESC_WRO_EN	(1 << 11) /* Tx Desc writeback RO bit */
-#define IXGBE_DCA_TXCTRL_DATA_RRO_EN	(1 << 13) /* Tx rd data Relax Order */
+#define IXGBE_DCA_RXCTRL_DESC_DCA_EN	BIT(5)  /* Rx Desc enable */
+#define IXGBE_DCA_RXCTRL_HEAD_DCA_EN	BIT(6)  /* Rx Desc header ena */
+#define IXGBE_DCA_RXCTRL_DATA_DCA_EN	BIT(7)  /* Rx Desc payload ena */
+#define IXGBE_DCA_RXCTRL_DESC_RRO_EN	BIT(9)  /* Rx rd Desc Relax Order */
+#define IXGBE_DCA_RXCTRL_DATA_WRO_EN	BIT(13) /* Rx wr data Relax Order */
+#define IXGBE_DCA_RXCTRL_HEAD_WRO_EN	BIT(15) /* Rx wr header RO */
+
+#define IXGBE_DCA_TXCTRL_DESC_DCA_EN	BIT(5)  /* DCA Tx Desc enable */
+#define IXGBE_DCA_TXCTRL_DESC_RRO_EN	BIT(9)  /* Tx rd Desc Relax Order */
+#define IXGBE_DCA_TXCTRL_DESC_WRO_EN	BIT(11) /* Tx Desc writeback RO bit */
+#define IXGBE_DCA_TXCTRL_DATA_RRO_EN	BIT(13) /* Tx rd data Relax Order */
 
 #endif /* _IXGBEVF_DEFINES_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 64d5c6e..508e72c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -166,7 +166,8 @@ static void ixgbevf_get_regs(struct net_device *netdev,
 
 	memset(p, 0, regs_len);
 
-	regs->version = (1 << 24) | hw->revision_id << 16 | hw->device_id;
+	/* generate a number suitable for ethtool's register version */
+	regs->version = (1u << 24) | (hw->revision_id << 16) | hw->device_id;
 
 	/* General Registers */
 	regs_buff[0] = IXGBE_READ_REG(hw, IXGBE_VFCTRL);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 5ca3794..aa28c4f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -166,10 +166,10 @@ struct ixgbevf_ring {
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 
-#define IXGBE_TX_FLAGS_CSUM		(u32)(1)
-#define IXGBE_TX_FLAGS_VLAN		(u32)(1 << 1)
-#define IXGBE_TX_FLAGS_TSO		(u32)(1 << 2)
-#define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 3)
+#define IXGBE_TX_FLAGS_CSUM		BIT(0)
+#define IXGBE_TX_FLAGS_VLAN		BIT(1)
+#define IXGBE_TX_FLAGS_TSO		BIT(2)
+#define IXGBE_TX_FLAGS_IPV4		BIT(3)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 007cbe0..e4e6060 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1056,7 +1056,7 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
 	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
 		ixgbevf_irq_enable_queues(adapter,
-					  1 << q_vector->v_idx);
+					  BIT(q_vector->v_idx));
 
 	return 0;
 }
@@ -1158,14 +1158,14 @@ static void ixgbevf_configure_msix(struct ixgbevf_adapter *adapter)
 		}
 
 		/* add q_vector eims value to global eims_enable_mask */
-		adapter->eims_enable_mask |= 1 << v_idx;
+		adapter->eims_enable_mask |= BIT(v_idx);
 
 		ixgbevf_write_eitr(q_vector);
 	}
 
 	ixgbevf_set_ivar(adapter, -1, 1, v_idx);
 	/* setup eims_other and add value to global eims_enable_mask */
-	adapter->eims_other = 1 << v_idx;
+	adapter->eims_other = BIT(v_idx);
 	adapter->eims_enable_mask |= adapter->eims_other;
 }
 
@@ -1589,8 +1589,8 @@ static void ixgbevf_configure_tx_ring(struct ixgbevf_adapter *adapter,
 	txdctl |= (8 << 16);    /* WTHRESH = 8 */
 
 	/* Setting PTHRESH to 32 both improves performance */
-	txdctl |= (1 << 8) |    /* HTHRESH = 1 */
-		  32;          /* PTHRESH = 32 */
+	txdctl |= (1u << 8) |    /* HTHRESH = 1 */
+		   32;           /* PTHRESH = 32 */
 
 	clear_bit(__IXGBEVF_HANG_CHECK_ARMED, &ring->state);
 
@@ -1646,7 +1646,7 @@ static void ixgbevf_setup_psrtype(struct ixgbevf_adapter *adapter)
 		      IXGBE_PSRTYPE_L2HDR;
 
 	if (adapter->num_rx_queues > 1)
-		psrtype |= 1 << 29;
+		psrtype |= BIT(29);
 
 	IXGBE_WRITE_REG(hw, IXGBE_VFPSRTYPE, psrtype);
 }
@@ -2797,7 +2797,7 @@ static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 		struct ixgbevf_q_vector *qv = adapter->q_vector[i];
 
 		if (qv->rx.ring || qv->tx.ring)
-			eics |= 1 << i;
+			eics |= BIT(i);
 	}
 
 	/* Cause software interrupt to ensure rings are cleaned */
@@ -3325,7 +3325,7 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	/* mss_l4len_id: use 1 as index for TSO */
 	mss_l4len_idx = l4len << IXGBE_ADVTXD_L4LEN_SHIFT;
 	mss_l4len_idx |= skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
-	mss_l4len_idx |= 1 << IXGBE_ADVTXD_IDX_SHIFT;
+	mss_l4len_idx |= (1u << IXGBE_ADVTXD_IDX_SHIFT);
 
 	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
 	vlan_macip_lens = skb_network_header_len(skb);
@@ -3422,7 +3422,7 @@ static void ixgbevf_tx_olinfo_status(union ixgbe_adv_tx_desc *tx_desc,
 
 	/* use index 1 context for TSO/FSO/FCOE */
 	if (tx_flags & IXGBE_TX_FLAGS_TSO)
-		olinfo_status |= cpu_to_le32(1 << IXGBE_ADVTXD_IDX_SHIFT);
+		olinfo_status |= cpu_to_le32(1u << IXGBE_ADVTXD_IDX_SHIFT);
 
 	/* Check Context must be set if Tx switch is enabled, which it
 	 * always is for case where virtual functions are running
-- 
2.5.5
