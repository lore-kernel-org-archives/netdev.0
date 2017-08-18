From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 09/14] amd-xgbe: Add hardware features debug
 output
Date: Thu, 17 Aug 2017 19:03:26 -0500
Message-ID: <20170818000326.10005.31325.stgit@tlendack-t1.amdoffice.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0070.outbound.protection.outlook.com ([104.47.40.70]:32293
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753887AbdHRADa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:03:30 -0400
In-Reply-To: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the dynamic debug support to output information about the hardware
features reported by the device.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   78 +++++++++++++++++++++++++++++-
 1 file changed, 75 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index d6d29d8..7498bb8 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -732,8 +732,6 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 	unsigned int mac_hfr0, mac_hfr1, mac_hfr2;
 	struct xgbe_hw_features *hw_feat = &pdata->hw_feat;
 
-	DBGPR("-->xgbe_get_all_hw_features\n");
-
 	mac_hfr0 = XGMAC_IOREAD(pdata, MAC_HWF0R);
 	mac_hfr1 = XGMAC_IOREAD(pdata, MAC_HWF1R);
 	mac_hfr2 = XGMAC_IOREAD(pdata, MAC_HWF2R);
@@ -828,7 +826,81 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 	hw_feat->rx_fifo_size = 1 << (hw_feat->rx_fifo_size + 7);
 	hw_feat->tx_fifo_size = 1 << (hw_feat->tx_fifo_size + 7);
 
-	DBGPR("<--xgbe_get_all_hw_features\n");
+	if (netif_msg_probe(pdata)) {
+		dev_dbg(pdata->dev, "Hardware features:\n");
+
+		/* Hardware feature register 0 */
+		dev_dbg(pdata->dev, "  1GbE support              : %s\n",
+			hw_feat->gmii ? "yes" : "no");
+		dev_dbg(pdata->dev, "  VLAN hash filter          : %s\n",
+			hw_feat->vlhash ? "yes" : "no");
+		dev_dbg(pdata->dev, "  MDIO interface            : %s\n",
+			hw_feat->sma ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Wake-up packet support    : %s\n",
+			hw_feat->rwk ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Magic packet support      : %s\n",
+			hw_feat->mgk ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Management counters       : %s\n",
+			hw_feat->mmc ? "yes" : "no");
+		dev_dbg(pdata->dev, "  ARP offload               : %s\n",
+			hw_feat->aoe ? "yes" : "no");
+		dev_dbg(pdata->dev, "  IEEE 1588-2008 Timestamp  : %s\n",
+			hw_feat->ts ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Energy Efficient Ethernet : %s\n",
+			hw_feat->eee ? "yes" : "no");
+		dev_dbg(pdata->dev, "  TX checksum offload       : %s\n",
+			hw_feat->tx_coe ? "yes" : "no");
+		dev_dbg(pdata->dev, "  RX checksum offload       : %s\n",
+			hw_feat->rx_coe ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Additional MAC addresses  : %u\n",
+			hw_feat->addn_mac);
+		dev_dbg(pdata->dev, "  Timestamp source          : %s\n",
+			(hw_feat->ts_src == 1) ? "internal" :
+			(hw_feat->ts_src == 2) ? "external" :
+			(hw_feat->ts_src == 3) ? "internal/external" : "n/a");
+		dev_dbg(pdata->dev, "  SA/VLAN insertion         : %s\n",
+			hw_feat->sa_vlan_ins ? "yes" : "no");
+
+		/* Hardware feature register 1 */
+		dev_dbg(pdata->dev, "  RX fifo size              : %u\n",
+			hw_feat->rx_fifo_size);
+		dev_dbg(pdata->dev, "  TX fifo size              : %u\n",
+			hw_feat->tx_fifo_size);
+		dev_dbg(pdata->dev, "  IEEE 1588 high word       : %s\n",
+			hw_feat->adv_ts_hi ? "yes" : "no");
+		dev_dbg(pdata->dev, "  DMA width                 : %u\n",
+			hw_feat->dma_width);
+		dev_dbg(pdata->dev, "  Data Center Bridging      : %s\n",
+			hw_feat->dcb ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Split header              : %s\n",
+			hw_feat->sph ? "yes" : "no");
+		dev_dbg(pdata->dev, "  TCP Segmentation Offload  : %s\n",
+			hw_feat->tso ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Debug memory interface    : %s\n",
+			hw_feat->dma_debug ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Receive Side Scaling      : %s\n",
+			hw_feat->rss ? "yes" : "no");
+		dev_dbg(pdata->dev, "  Traffic Class count       : %u\n",
+			hw_feat->tc_cnt);
+		dev_dbg(pdata->dev, "  Hash table size           : %u\n",
+			hw_feat->hash_table_size);
+		dev_dbg(pdata->dev, "  L3/L4 Filters             : %u\n",
+			hw_feat->l3l4_filter_num);
+
+		/* Hardware feature register 2 */
+		dev_dbg(pdata->dev, "  RX queue count            : %u\n",
+			hw_feat->rx_q_cnt);
+		dev_dbg(pdata->dev, "  TX queue count            : %u\n",
+			hw_feat->tx_q_cnt);
+		dev_dbg(pdata->dev, "  RX DMA channel count      : %u\n",
+			hw_feat->rx_ch_cnt);
+		dev_dbg(pdata->dev, "  TX DMA channel count      : %u\n",
+			hw_feat->rx_ch_cnt);
+		dev_dbg(pdata->dev, "  PPS outputs               : %u\n",
+			hw_feat->pps_out_num);
+		dev_dbg(pdata->dev, "  Auxiliary snapshot inputs : %u\n",
+			hw_feat->aux_snap_num);
+	}
 }
 
 static void xgbe_napi_enable(struct xgbe_prv_data *pdata, unsigned int add)
