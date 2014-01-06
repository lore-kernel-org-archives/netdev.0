From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH v3 3/5] alx: add stats update function
Date: Mon,  6 Jan 2014 17:33:41 +0100
Message-ID: <1389026023-18743-4-git-send-email-sd@queasysnail.net>
References: <1389026023-18743-1-git-send-email-sd@queasysnail.net>
Cc: bhutchings@solarflare.com, johannes@sipsolutions.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:44887 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755693AbaAFQf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 11:35:27 -0500
In-Reply-To: <1389026023-18743-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/atheros/alx/hw.c | 58 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/atheros/alx/hw.h |  4 +++
 2 files changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
index 1e8c24a..7712f06 100644
--- a/drivers/net/ethernet/atheros/alx/hw.c
+++ b/drivers/net/ethernet/atheros/alx/hw.c
@@ -1050,3 +1050,61 @@ bool alx_get_phy_info(struct alx_hw *hw)
 
 	return true;
 }
+
+void alx_update_hw_stats(struct alx_hw *hw)
+{
+	/* RX stats */
+	hw->stats.rx_ok          += alx_read_mem32(hw, ALX_MIB_RX_OK);
+	hw->stats.rx_bcast       += alx_read_mem32(hw, ALX_MIB_RX_BCAST);
+	hw->stats.rx_mcast       += alx_read_mem32(hw, ALX_MIB_RX_MCAST);
+	hw->stats.rx_pause       += alx_read_mem32(hw, ALX_MIB_RX_PAUSE);
+	hw->stats.rx_ctrl        += alx_read_mem32(hw, ALX_MIB_RX_CTRL);
+	hw->stats.rx_fcs_err     += alx_read_mem32(hw, ALX_MIB_RX_FCS_ERR);
+	hw->stats.rx_len_err     += alx_read_mem32(hw, ALX_MIB_RX_LEN_ERR);
+	hw->stats.rx_byte_cnt    += alx_read_mem32(hw, ALX_MIB_RX_BYTE_CNT);
+	hw->stats.rx_runt        += alx_read_mem32(hw, ALX_MIB_RX_RUNT);
+	hw->stats.rx_frag        += alx_read_mem32(hw, ALX_MIB_RX_FRAG);
+	hw->stats.rx_sz_64B      += alx_read_mem32(hw, ALX_MIB_RX_SZ_64B);
+	hw->stats.rx_sz_127B     += alx_read_mem32(hw, ALX_MIB_RX_SZ_127B);
+	hw->stats.rx_sz_255B     += alx_read_mem32(hw, ALX_MIB_RX_SZ_255B);
+	hw->stats.rx_sz_511B     += alx_read_mem32(hw, ALX_MIB_RX_SZ_511B);
+	hw->stats.rx_sz_1023B    += alx_read_mem32(hw, ALX_MIB_RX_SZ_1023B);
+	hw->stats.rx_sz_1518B    += alx_read_mem32(hw, ALX_MIB_RX_SZ_1518B);
+	hw->stats.rx_sz_max      += alx_read_mem32(hw, ALX_MIB_RX_SZ_MAX);
+	hw->stats.rx_ov_sz       += alx_read_mem32(hw, ALX_MIB_RX_OV_SZ);
+	hw->stats.rx_ov_rxf      += alx_read_mem32(hw, ALX_MIB_RX_OV_RXF);
+	hw->stats.rx_ov_rrd      += alx_read_mem32(hw, ALX_MIB_RX_OV_RRD);
+	hw->stats.rx_align_err   += alx_read_mem32(hw, ALX_MIB_RX_ALIGN_ERR);
+	hw->stats.rx_bc_byte_cnt += alx_read_mem32(hw, ALX_MIB_RX_BCCNT);
+	hw->stats.rx_mc_byte_cnt += alx_read_mem32(hw, ALX_MIB_RX_MCCNT);
+	hw->stats.rx_err_addr    += alx_read_mem32(hw, ALX_MIB_RX_ERRADDR);
+
+	/* TX stats */
+	hw->stats.tx_ok          += alx_read_mem32(hw, ALX_MIB_TX_OK);
+	hw->stats.tx_bcast       += alx_read_mem32(hw, ALX_MIB_TX_BCAST);
+	hw->stats.tx_mcast       += alx_read_mem32(hw, ALX_MIB_TX_MCAST);
+	hw->stats.tx_pause       += alx_read_mem32(hw, ALX_MIB_TX_PAUSE);
+	hw->stats.tx_exc_defer   += alx_read_mem32(hw, ALX_MIB_TX_EXC_DEFER);
+	hw->stats.tx_ctrl        += alx_read_mem32(hw, ALX_MIB_TX_CTRL);
+	hw->stats.tx_defer       += alx_read_mem32(hw, ALX_MIB_TX_DEFER);
+	hw->stats.tx_byte_cnt    += alx_read_mem32(hw, ALX_MIB_TX_BYTE_CNT);
+	hw->stats.tx_sz_64B      += alx_read_mem32(hw, ALX_MIB_TX_SZ_64B);
+	hw->stats.tx_sz_127B     += alx_read_mem32(hw, ALX_MIB_TX_SZ_127B);
+	hw->stats.tx_sz_255B     += alx_read_mem32(hw, ALX_MIB_TX_SZ_255B);
+	hw->stats.tx_sz_511B     += alx_read_mem32(hw, ALX_MIB_TX_SZ_511B);
+	hw->stats.tx_sz_1023B    += alx_read_mem32(hw, ALX_MIB_TX_SZ_1023B);
+	hw->stats.tx_sz_1518B    += alx_read_mem32(hw, ALX_MIB_TX_SZ_1518B);
+	hw->stats.tx_sz_max      += alx_read_mem32(hw, ALX_MIB_TX_SZ_MAX);
+	hw->stats.tx_single_col  += alx_read_mem32(hw, ALX_MIB_TX_SINGLE_COL);
+	hw->stats.tx_multi_col   += alx_read_mem32(hw, ALX_MIB_TX_MULTI_COL);
+	hw->stats.tx_late_col    += alx_read_mem32(hw, ALX_MIB_TX_LATE_COL);
+	hw->stats.tx_abort_col   += alx_read_mem32(hw, ALX_MIB_TX_ABORT_COL);
+	hw->stats.tx_underrun    += alx_read_mem32(hw, ALX_MIB_TX_UNDERRUN);
+	hw->stats.tx_trd_eop     += alx_read_mem32(hw, ALX_MIB_TX_TRD_EOP);
+	hw->stats.tx_len_err     += alx_read_mem32(hw, ALX_MIB_TX_LEN_ERR);
+	hw->stats.tx_trunc       += alx_read_mem32(hw, ALX_MIB_TX_TRUNC);
+	hw->stats.tx_bc_byte_cnt += alx_read_mem32(hw, ALX_MIB_TX_BCCNT);
+	hw->stats.tx_mc_byte_cnt += alx_read_mem32(hw, ALX_MIB_TX_MCCNT);
+
+	hw->stats.update         += alx_read_mem32(hw, ALX_MIB_UPDATE);
+}
diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index 1c1a0ee..a97edfb 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -482,6 +482,9 @@ struct alx_hw {
 
 	/* PHY link patch flag */
 	bool lnk_patch;
+
+	/* cumulated stats from the hardware (registers are cleared on read) */
+	struct alx_hw_stats stats;
 };
 
 static inline int alx_hw_revision(struct alx_hw *hw)
@@ -549,6 +552,7 @@ bool alx_phy_configured(struct alx_hw *hw);
 void alx_configure_basic(struct alx_hw *hw);
 void alx_disable_rss(struct alx_hw *hw);
 bool alx_get_phy_info(struct alx_hw *hw);
+void alx_update_hw_stats(struct alx_hw *hw);
 
 static inline u32 alx_speed_to_ethadv(int speed, u8 duplex)
 {
-- 
1.8.5.2
