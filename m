From: Phil Reid <preid@electromag.com.au>
Subject: [1/1] stmmac: Correctly report PTP capabilities.
Date: Fri, 30 Oct 2015 16:43:55 +0800
Message-ID: <1446194635-19782-2-git-send-email-preid@electromag.com.au>
References: <1446194635-19782-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: peppe.cavallaro@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:58249 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758604AbbJ3Ixr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 04:53:47 -0400
In-Reply-To: <1446194635-19782-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

priv->hwts_*_en indicate if timestamping is enabled/disabled at run
time. But  priv->dma_cap.time_stamp  and priv->dma_cap.atime_stamp
indicates HW is support for PTPv1/PTPv2.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 771cda2..2e51b81 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -721,10 +721,13 @@ static int stmmac_get_ts_info(struct net_device *dev,
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	if ((priv->hwts_tx_en) && (priv->hwts_rx_en)) {
+	if ((priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp)) {
 
-		info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
+		info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+					SOF_TIMESTAMPING_TX_HARDWARE |
+					SOF_TIMESTAMPING_RX_SOFTWARE |
 					SOF_TIMESTAMPING_RX_HARDWARE |
+					SOF_TIMESTAMPING_SOFTWARE |
 					SOF_TIMESTAMPING_RAW_HARDWARE;
 
 		if (priv->ptp_clock)
-- 
1.8.3.1
