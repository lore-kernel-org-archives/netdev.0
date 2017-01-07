From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] intel: Use upper_32_bits and lower_32_bits
Date: Sat,  7 Jan 2017 10:32:30 -0800
Message-ID: <7a5cfe63cad3ef4badc30cbc2185a5bfb9250fd8.1483813334.git.joe@perches.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shifting and masking various types can be made a bit
simpler to read by using the available kernel macros.

Signed-off-by: Joe Perches <joe@perches.com>
---

This RFC patch is meant as an example, not necessarily
to apply, though it does compile to equivalent code.

It does seem a bit simpler for a human to read.

Perhaps this could be automated via a coccinelle script,
but this was done with grep & sed and some typing.

Treewide, there are many hundred instances of this style code
that could be converted.

Dunno if it's really worth it though.

Another usage that could be converted is DMA_BIT_MASK(32)
where it is equivalent to upper_32_bits and lower_32_bits.

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |  8 ++++----
 drivers/net/ethernet/intel/e1000/e1000_main.c      |  8 ++++----
 drivers/net/ethernet/intel/e1000e/ethtool.c        |  8 ++++----
 drivers/net/ethernet/intel/fm10k/fm10k_common.c    |  4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c        |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         | 12 ++++++------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  9 +++++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c          | 10 ++++------
 drivers/net/ethernet/intel/igb/igb_ptp.c           |  4 ++--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        | 12 ++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |  4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   | 12 ++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 16 ++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       | 12 ++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      |  4 ++--
 19 files changed, 72 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 975eeb885ca2..11ad95f34f4f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1021,8 +1021,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	}
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
-	ew32(TDBAL, ((u64)txdr->dma & 0x00000000FFFFFFFF));
-	ew32(TDBAH, ((u64)txdr->dma >> 32));
+	ew32(TDBAL, lower_32_bits(txdr->dma));
+	ew32(TDBAH, upper_32_bits(txdr->dma));
 	ew32(TDLEN, txdr->count * sizeof(struct e1000_tx_desc));
 	ew32(TDH, 0);
 	ew32(TDT, 0);
@@ -1081,8 +1081,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	rctl = er32(RCTL);
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
-	ew32(RDBAL, ((u64)rxdr->dma & 0xFFFFFFFF));
-	ew32(RDBAH, ((u64)rxdr->dma >> 32));
+	ew32(RDBAL, lower_32_bits(rxdr->dma));
+	ew32(RDBAH, upper_32_bits(rxdr->dma));
 	ew32(RDLEN, rxdr->size);
 	ew32(RDH, 0);
 	ew32(RDT, 0);
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 93fc6c67306b..d222f731f280 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1614,8 +1614,8 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		tdlen = adapter->tx_ring[0].count *
 			sizeof(struct e1000_tx_desc);
 		ew32(TDLEN, tdlen);
-		ew32(TDBAH, (tdba >> 32));
-		ew32(TDBAL, (tdba & 0x00000000ffffffffULL));
+		ew32(TDBAH, upper_32_bits(tdba));
+		ew32(TDBAL, lower_32_bits(tdba));
 		ew32(TDT, 0);
 		ew32(TDH, 0);
 		adapter->tx_ring[0].tdh = ((hw->mac_type >= e1000_82543) ?
@@ -1896,8 +1896,8 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	default:
 		rdba = adapter->rx_ring[0].dma;
 		ew32(RDLEN, rdlen);
-		ew32(RDBAH, (rdba >> 32));
-		ew32(RDBAL, (rdba & 0x00000000ffffffffULL));
+		ew32(RDBAH, upper_32_bits(rdba));
+		ew32(RDBAL, lower_32_bits(rdba));
 		ew32(RDT, 0);
 		ew32(RDH, 0);
 		adapter->rx_ring[0].rdh = ((hw->mac_type >= e1000_82543) ?
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 7aff68a4a4df..35304b380eaa 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1203,8 +1203,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
-	ew32(TDBAL(0), ((u64)tx_ring->dma & 0x00000000FFFFFFFF));
-	ew32(TDBAH(0), ((u64)tx_ring->dma >> 32));
+	ew32(TDBAL(0), lower_32_bits(tx_ring->dma));
+	ew32(TDBAH(0), upper_32_bits(tx_ring->dma));
 	ew32(TDLEN(0), tx_ring->count * sizeof(struct e1000_tx_desc));
 	ew32(TDH(0), 0);
 	ew32(TDT(0), 0);
@@ -1266,8 +1266,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rctl = er32(RCTL);
 	if (!(adapter->flags2 & FLAG2_NO_DISABLE_RX))
 		ew32(RCTL, rctl & ~E1000_RCTL_EN);
-	ew32(RDBAL(0), ((u64)rx_ring->dma & 0xFFFFFFFF));
-	ew32(RDBAH(0), ((u64)rx_ring->dma >> 32));
+	ew32(RDBAL(0), lower_32_bits(rx_ring->dma));
+	ew32(RDBAH(0), upper_32_bits(rx_ring->dma));
 	ew32(RDLEN(0), rx_ring->size);
 	ew32(RDH(0), 0);
 	ew32(RDT(0), 0);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.c b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
index dd95ac4f4c64..72d428f598b3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.c
@@ -325,10 +325,10 @@ static void fm10k_update_hw_base_48b(struct fm10k_hw_stat *stat, u64 delta)
 
 	/* update lower 32 bits */
 	delta += stat->base_l;
-	stat->base_l = (u32)delta;
+	stat->base_l = lower_32_bits(delta);
 
 	/* update upper 32 bits */
-	stat->base_h += (u32)(delta >> 32);
+	stat->base_h += upper_32_bits(delta);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 23fb319fd2a0..e0cc9883710b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1548,7 +1548,7 @@ static void fm10k_rebind_hw_stats_pf(struct fm10k_hw *hw,
 static void fm10k_set_dma_mask_pf(struct fm10k_hw *hw, u64 dma_mask)
 {
 	/* we need to write the upper 32 bits of DMA mask to PhyAddrSpace */
-	u32 phyaddr = (u32)(dma_mask >> 32);
+	u32 phyaddr = upper_32_bits(dma_mask);
 
 	fm10k_write_reg(hw, FM10K_PHYADDR, phyaddr);
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 128735975caa..b184487eb49a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2984,8 +2984,8 @@ i40e_status i40e_aq_debug_write_register(struct i40e_hw *hw,
 	i40e_fill_default_direct_cmd_desc(&desc, i40e_aqc_opc_debug_write_reg);
 
 	cmd->address = cpu_to_le32(reg_addr);
-	cmd->value_high = cpu_to_le32((u32)(reg_val >> 32));
-	cmd->value_low = cpu_to_le32((u32)(reg_val & 0xFFFFFFFF));
+	cmd->value_high = cpu_to_le32(upper_32_bits(reg_val));
+	cmd->value_low = cpu_to_le32(lower_32_bits(reg_val));
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index cc1465aac2ef..091ac00053bd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2550,14 +2550,14 @@ static int i40e_set_rss_hash_opt(struct i40e_pf *pf, struct ethtool_rxnfc *nfc)
 					       flow_pctype)) << 32);
 		i_set = i40e_get_rss_hash_bits(nfc, i_setc);
 		i40e_write_rx_ctl(hw, I40E_GLQF_HASH_INSET(0, flow_pctype),
-				  (u32)i_set);
+				  lower_32_bits(i_set));
 		i40e_write_rx_ctl(hw, I40E_GLQF_HASH_INSET(1, flow_pctype),
-				  (u32)(i_set >> 32));
+				  upper_32_bits(i_set));
 		hena |= BIT_ULL(flow_pctype);
 	}
 
-	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(0), (u32)hena);
-	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
+	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(0), lower_32_bits(hena));
+	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), upper_32_bits(hena));
 	i40e_flush(hw);
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ad4cf639430e..219c696411f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8410,8 +8410,8 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
 		((u64)i40e_read_rx_ctl(hw, I40E_PFQF_HENA(1)) << 32);
 	hena |= i40e_pf_get_default_rss_hena(pf);
 
-	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(0), (u32)hena);
-	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
+	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(0), lower_32_bits(hena));
+	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), upper_32_bits(hena));
 
 	/* Determine the RSS table size based on the hardware capabilities */
 	reg_val = i40e_read_rx_ctl(hw, I40E_PFQF_CTL_0);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 9e49ffafce28..b2566ce83505 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -88,8 +88,8 @@ static void i40e_ptp_write(struct i40e_pf *pf, const struct timespec64 *ts)
 	/* The timer will not update until the high register is written, so
 	 * write the low register first.
 	 */
-	wr32(hw, I40E_PRTTSYN_TIME_L, ns & 0xFFFFFFFF);
-	wr32(hw, I40E_PRTTSYN_TIME_H, ns >> 32);
+	wr32(hw, I40E_PRTTSYN_TIME_L, lower_32_bits(ns));
+	wr32(hw, I40E_PRTTSYN_TIME_H, upper_32_bits(ns));
 }
 
 /**
@@ -141,8 +141,8 @@ static int i40e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	else
 		adj += diff;
 
-	wr32(hw, I40E_PRTTSYN_INC_L, adj & 0xFFFFFFFF);
-	wr32(hw, I40E_PRTTSYN_INC_H, adj >> 32);
+	wr32(hw, I40E_PRTTSYN_INC_L, lower_32_bits(adj));
+	wr32(hw, I40E_PRTTSYN_INC_H, upper_32_bits(adj));
 
 	return 0;
 }
@@ -447,8 +447,8 @@ void i40e_ptp_set_increment(struct i40e_pf *pf)
 	 * hardware will not update the clock until both registers have been
 	 * written.
 	 */
-	wr32(hw, I40E_PRTTSYN_INC_L, incval & 0xFFFFFFFF);
-	wr32(hw, I40E_PRTTSYN_INC_H, incval >> 32);
+	wr32(hw, I40E_PRTTSYN_INC_L, lower_32_bits(incval));
+	wr32(hw, I40E_PRTTSYN_INC_H, upper_32_bits(incval));
 
 	/* Update the base adjustement value. */
 	ACCESS_ONCE(pf->ptp_base_adj) = incval;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 0fb899efbad3..d8cb9aea07a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -705,9 +705,9 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 				 "Could not allocate VF broadcast filter\n");
 		spin_unlock_bh(&vsi->mac_filter_hash_lock);
 		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(0, vf->vf_id),
-				  (u32)hena);
+				  lower_32_bits(hena));
 		i40e_write_rx_ctl(&pf->hw, I40E_VFQF_HENA1(1, vf->vf_id),
-				  (u32)(hena >> 32));
+				  upper_32_bits(hena));
 	}
 
 	/* program mac filter */
@@ -2349,9 +2349,10 @@ static int i40e_vc_set_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		aq_ret = I40E_ERR_PARAM;
 		goto err;
 	}
-	i40e_write_rx_ctl(hw, I40E_VFQF_HENA1(0, vf->vf_id), (u32)vrh->hena);
+	i40e_write_rx_ctl(hw, I40E_VFQF_HENA1(0, vf->vf_id),
+			  lower_32_bits(vrh->hena));
 	i40e_write_rx_ctl(hw, I40E_VFQF_HENA1(1, vf->vf_id),
-			  (u32)(vrh->hena >> 32));
+			  upper_32_bits(vrh->hena));
 
 	/* send the response to the VF */
 err:
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index c0fc53361800..089a1e87ced8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1379,8 +1379,8 @@ static int i40evf_init_rss(struct i40evf_adapter *adapter)
 		else
 			adapter->hena = I40E_DEFAULT_RSS_HENA;
 
-		wr32(hw, I40E_VFQF_HENA(0), (u32)adapter->hena);
-		wr32(hw, I40E_VFQF_HENA(1), (u32)(adapter->hena >> 32));
+		wr32(hw, I40E_VFQF_HENA(0), lower_32_bits(adapter->hena));
+		wr32(hw, I40E_VFQF_HENA(1), upper_32_bits(adapter->hena));
 	}
 
 	i40evf_fill_rss_lut(adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a761001308dc..a2fd0b6019cf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3390,9 +3390,8 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 
 	wr32(E1000_TDLEN(reg_idx),
 	     ring->count * sizeof(union e1000_adv_tx_desc));
-	wr32(E1000_TDBAL(reg_idx),
-	     tdba & 0x00000000ffffffffULL);
-	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
+	wr32(E1000_TDBAL(reg_idx), lower_32_bits(tdba));
+	wr32(E1000_TDBAH(reg_idx), upper_32_bits(tdba));
 
 	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
 	wr32(E1000_TDH(reg_idx), 0);
@@ -3726,9 +3725,8 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	wr32(E1000_RXDCTL(reg_idx), 0);
 
 	/* Set DMA base address registers */
-	wr32(E1000_RDBAL(reg_idx),
-	     rdba & 0x00000000ffffffffULL);
-	wr32(E1000_RDBAH(reg_idx), rdba >> 32);
+	wr32(E1000_RDBAL(reg_idx), lower_32_bits(rdba));
+	wr32(E1000_RDBAH(reg_idx), upper_32_bits(rdba));
 	wr32(E1000_RDLEN(reg_idx),
 	     ring->count * sizeof(union e1000_adv_rx_desc));
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index c4477552ce9e..67559c73e0e7 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -188,8 +188,8 @@ static void igb_ptp_systim_to_hwtstamp(struct igb_adapter *adapter,
 	case e1000_i211:
 		memset(hwtstamps, 0, sizeof(*hwtstamps));
 		/* Upper 32 bits contain s, lower 32 bits contain ns. */
-		hwtstamps->hwtstamp = ktime_set(systim >> 32,
-						systim & 0xFFFFFFFF);
+		hwtstamps->hwtstamp = ktime_set(upper_32_bits(systim),
+						lower_32_bits(systim));
 		break;
 	default:
 		break;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5826b1ddedcf..a23e99528d5e 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -749,8 +749,8 @@ ixgb_configure_tx(struct ixgb_adapter *adapter)
 	 * tx_ring.dma can be either a 32 or 64 bit value
 	 */
 
-	IXGB_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
-	IXGB_WRITE_REG(hw, TDBAH, (tdba >> 32));
+	IXGB_WRITE_REG(hw, TDBAL, lower_32_bits(tdba));
+	IXGB_WRITE_REG(hw, TDBAH, upper_32_bits(tdba));
 
 	IXGB_WRITE_REG(hw, TDLEN, tdlen);
 
@@ -875,8 +875,8 @@ ixgb_configure_rx(struct ixgb_adapter *adapter)
 
 	/* Setup the Base and Length of the Rx Descriptor Ring */
 
-	IXGB_WRITE_REG(hw, RDBAL, (rdba & 0x00000000ffffffffULL));
-	IXGB_WRITE_REG(hw, RDBAH, (rdba >> 32));
+	IXGB_WRITE_REG(hw, RDBAL, lower_32_bits(rdba));
+	IXGB_WRITE_REG(hw, RDBAH, upper_32_bits(rdba));
 
 	IXGB_WRITE_REG(hw, RDLEN, rdlen);
 
@@ -1664,8 +1664,8 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 		if (multi >= bcast)
 			multi -= bcast;
 
-		adapter->stats.mprcl += (multi & 0xFFFFFFFF);
-		adapter->stats.mprch += (multi >> 32);
+		adapter->stats.mprcl += lower_32_bits(multi);
+		adapter->stats.mprch += upper_32_bits(multi);
 		adapter->stats.bprcl += bcast_l;
 		adapter->stats.bprch += bcast_h;
 	} else {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index e083732adf64..6237e6c2ed30 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -173,8 +173,8 @@ static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
 #define writeq writeq
 static inline void writeq(u64 val, void __iomem *addr)
 {
-	writel((u32)val, addr);
-	writel((u32)(val >> 32), addr + 4);
+	writel(lower_32_bits(val), addr);
+	writel(upper_32_bits(val), addr + 4);
 }
 #endif
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 17589068da78..0d973e2d0937 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -748,10 +748,10 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[939] = IXGBE_GET_STAT(adapter, bprc);
 	regs_buff[940] = IXGBE_GET_STAT(adapter, mprc);
 	regs_buff[941] = IXGBE_GET_STAT(adapter, gptc);
-	regs_buff[942] = (u32)IXGBE_GET_STAT(adapter, gorc);
-	regs_buff[943] = (u32)(IXGBE_GET_STAT(adapter, gorc) >> 32);
-	regs_buff[944] = (u32)IXGBE_GET_STAT(adapter, gotc);
-	regs_buff[945] = (u32)(IXGBE_GET_STAT(adapter, gotc) >> 32);
+	regs_buff[942] = lower_32_bits(IXGBE_GET_STAT(adapter, gorc));
+	regs_buff[943] = upper_32_bits(IXGBE_GET_STAT(adapter, gorc));
+	regs_buff[944] = lower_32_bits(IXGBE_GET_STAT(adapter, gotc));
+	regs_buff[945] = upper_32_bits(IXGBE_GET_STAT(adapter, gotc));
 	for (i = 0; i < 8; i++)
 		regs_buff[946 + i] = IXGBE_GET_STAT(adapter, rnbc[i]);
 	regs_buff[954] = IXGBE_GET_STAT(adapter, ruc);
@@ -761,8 +761,8 @@ static void ixgbe_get_regs(struct net_device *netdev,
 	regs_buff[958] = IXGBE_GET_STAT(adapter, mngprc);
 	regs_buff[959] = IXGBE_GET_STAT(adapter, mngpdc);
 	regs_buff[960] = IXGBE_GET_STAT(adapter, mngptc);
-	regs_buff[961] = (u32)IXGBE_GET_STAT(adapter, tor);
-	regs_buff[962] = (u32)(IXGBE_GET_STAT(adapter, tor) >> 32);
+	regs_buff[961] = lower_32_bits(IXGBE_GET_STAT(adapter, tor));
+	regs_buff[962] = upper_32_bits(IXGBE_GET_STAT(adapter, tor));
 	regs_buff[963] = IXGBE_GET_STAT(adapter, tpr);
 	regs_buff[964] = IXGBE_GET_STAT(adapter, tpt);
 	regs_buff[965] = IXGBE_GET_STAT(adapter, ptc64);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0c6eca570791..71d054f6a2aa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -936,10 +936,10 @@ static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
 	case ixgbe_mac_x550em_a:
-		mask = (qmask & 0xFFFFFFFF);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(0), mask);
-		mask = (qmask >> 32);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(1), mask);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(0),
+				lower_32_bits(qmask));
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(1),
+				upper_32_bits(qmask));
 		break;
 	default:
 		break;
@@ -2650,10 +2650,10 @@ static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
 	case ixgbe_mac_x550em_a:
-		mask = (qmask & 0xFFFFFFFF);
+		mask = lower_32_bits(qmask);
 		if (mask)
 			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(0), mask);
-		mask = (qmask >> 32);
+		mask = upper_32_bits(qmask);
 		if (mask)
 			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(1), mask);
 		break;
@@ -2679,10 +2679,10 @@ static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
 	case ixgbe_mac_x550em_a:
-		mask = (qmask & 0xFFFFFFFF);
+		mask = lower_32_bits(qmask);
 		if (mask)
 			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(0), mask);
-		mask = (qmask >> 32);
+		mask = upper_32_bits(qmask);
 		if (mask)
 			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(1), mask);
 		break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index ef0635e0918c..a1cb0b99456c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -206,8 +206,8 @@ static void ixgbe_ptp_setup_sdp_x540(struct ixgbe_adapter *adapter)
 		 IXGBE_TSAUXC_SDP0_INT;
 
 	/* clock period (or pulse length) */
-	clktiml = (u32)(IXGBE_PTP_PPS_HALF_SECOND << shift);
-	clktimh = (u32)((IXGBE_PTP_PPS_HALF_SECOND << shift) >> 32);
+	clktiml = lower_32_bits(IXGBE_PTP_PPS_HALF_SECOND << shift);
+	clktimh = upper_32_bits(IXGBE_PTP_PPS_HALF_SECOND << shift);
 
 	/* Account for the cyclecounter wrap-around value by
 	 * using the converted ns value of the current time to
@@ -221,8 +221,8 @@ static void ixgbe_ptp_setup_sdp_x540(struct ixgbe_adapter *adapter)
 	clock_edge += ((IXGBE_PTP_PPS_HALF_SECOND - (u64)rem) << shift);
 
 	/* specify the initial clock start time */
-	trgttiml = (u32)clock_edge;
-	trgttimh = (u32)(clock_edge >> 32);
+	trgttiml = lower_32_bits(clock_edge);
+	trgttimh = upper_32_bits(clock_edge);
 
 	IXGBE_WRITE_REG(hw, IXGBE_CLKTIML, clktiml);
 	IXGBE_WRITE_REG(hw, IXGBE_CLKTIMH, clktimh);
@@ -339,8 +339,8 @@ static void ixgbe_ptp_convert_to_hwtstamp(struct ixgbe_adapter *adapter,
 		 * correct math even though the units haven't been corrected
 		 * yet.
 		 */
-		systime.tv_sec = timestamp >> 32;
-		systime.tv_nsec = timestamp & 0xFFFFFFFF;
+		systime.tv_sec = upper_32_bits(timestamp);
+		systime.tv_nsec = lower_32_bits(timestamp);
 
 		timestamp = timespec64_to_ns(&systime);
 		break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 200f847fd8f3..1d3ca7a5106f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3437,8 +3437,8 @@ static void ixgbe_set_source_address_pruning_X550(struct ixgbe_hw *hw,
 	else
 		pfflp &= ~(1ULL << pool);
 
-	IXGBE_WRITE_REG(hw, IXGBE_PFFLPL, (u32)pfflp);
-	IXGBE_WRITE_REG(hw, IXGBE_PFFLPH, (u32)(pfflp >> 32));
+	IXGBE_WRITE_REG(hw, IXGBE_PFFLPL, lower_32_bits(pfflp));
+	IXGBE_WRITE_REG(hw, IXGBE_PFFLPH, upper_32_bits(pfflp));
 }
 
 /**
-- 
2.10.0.rc2.1.g053435c
