From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 3/6] bnx2x: fix Big-Endianess in ethtool -t
Date: Mon, 23 Jan 2012 12:31:53 -0500
Message-ID: <1327339916-19138-4-git-send-email-yuvalmin@broadcom.com>
References: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3037 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088Ab2AWKhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jan 2012 05:37:47 -0500
In-Reply-To: <1327339916-19138-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 7d32e00..31a8b38 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1738,7 +1738,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	struct bnx2x_fp_txdata *txdata = &fp_tx->txdata[0];
 	u16 tx_start_idx, tx_idx;
 	u16 rx_start_idx, rx_idx;
-	u16 pkt_prod, bd_prod, rx_comp_cons;
+	u16 pkt_prod, bd_prod;
 	struct sw_tx_bd *tx_buf;
 	struct eth_tx_start_bd *tx_start_bd;
 	struct eth_tx_parse_bd_e1x  *pbd_e1x = NULL;
@@ -1873,8 +1873,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	if (rx_idx != rx_start_idx + num_pkts)
 		goto test_loopback_exit;
 
-	rx_comp_cons = le16_to_cpu(fp_rx->rx_comp_cons);
-	cqe = &fp_rx->rx_comp_ring[RCQ_BD(rx_comp_cons)];
+	cqe = &fp_rx->rx_comp_ring[RCQ_BD(fp_rx->rx_comp_cons)];
 	cqe_fp_flags = cqe->fast_path_cqe.type_error_flags;
 	cqe_fp_type = cqe_fp_flags & ETH_FAST_PATH_RX_CQE_TYPE;
 	if (!CQE_TYPE_FAST(cqe_fp_type) || (cqe_fp_flags & ETH_RX_ERROR_FALGS))
-- 
1.7.1
