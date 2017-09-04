From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix pause frame count in t4_get_port_stats
Date: Mon,  4 Sep 2017 11:17:36 +0530
Message-ID: <1504504056-21956-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:58429 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdIDFrp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 01:47:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPS_STAT_CTL[CountPauseStatTx] and MPS_STAT_CTL[CountPauseStatRx]
only control whether or not Pause Frames will be counted as part
of the 64-Byte Tx/Rx Frame counters.  These bits do not control
whether Pause Frames are counted in the Total Tx/Rx Frames/Bytes
counters.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index b0f9aea..b65ce26 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -6001,10 +6001,8 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 	p->tx_ppp7             = GET_STAT(TX_PORT_PPP7);
 
 	if (CHELSIO_CHIP_VERSION(adap->params.chip) >= CHELSIO_T5) {
-		if (stat_ctl & COUNTPAUSESTATTX_F) {
-			p->tx_frames -= p->tx_pause;
-			p->tx_octets -= p->tx_pause * 64;
-		}
+		if (stat_ctl & COUNTPAUSESTATTX_F)
+			p->tx_frames_64 -= p->tx_pause;
 		if (stat_ctl & COUNTPAUSEMCTX_F)
 			p->tx_mcast_frames -= p->tx_pause;
 	}
@@ -6037,10 +6035,8 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p)
 	p->rx_ppp7             = GET_STAT(RX_PORT_PPP7);
 
 	if (CHELSIO_CHIP_VERSION(adap->params.chip) >= CHELSIO_T5) {
-		if (stat_ctl & COUNTPAUSESTATRX_F) {
-			p->rx_frames -= p->rx_pause;
-			p->rx_octets -= p->rx_pause * 64;
-		}
+		if (stat_ctl & COUNTPAUSESTATRX_F)
+			p->rx_frames_64 -= p->rx_pause;
 		if (stat_ctl & COUNTPAUSEMCRX_F)
 			p->rx_mcast_frames -= p->rx_pause;
 	}
-- 
2.1.0
