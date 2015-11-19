From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/2] bnx2x: Add new SW stat 'tx_exhaustion_events'
Date: Thu, 19 Nov 2015 17:04:35 +0200
Message-ID: <1447945476-26945-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1447945476-26945-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62258 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758698AbbKSPEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 10:04:46 -0500
In-Reply-To: <1447945476-26945-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver already has an internal counter for number of times a given queue
had to be stopped due to Tx ring exhaustion.
This add the counter to the statistics presented by driver, e.g., by using
`ethtool -S'.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index d84efcd..1dc77ac 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -52,7 +52,7 @@ static const struct {
 	{ Q_STATS_OFFSET32(rx_skb_alloc_failed),
 					 4, "[%s]: rx_skb_alloc_discard" },
 	{ Q_STATS_OFFSET32(hw_csum_err), 4, "[%s]: rx_csum_offload_errors" },
-
+	{ Q_STATS_OFFSET32(driver_xoff), 4, "[%s]: tx_exhaustion_events" },
 	{ Q_STATS_OFFSET32(total_bytes_transmitted_hi),	8, "[%s]: tx_bytes" },
 /* 10 */{ Q_STATS_OFFSET32(total_unicast_packets_transmitted_hi),
 						8, "[%s]: tx_ucast_packets" },
@@ -128,7 +128,8 @@ static const struct {
 				4, STATS_FLAGS_BOTH, "rx_skb_alloc_discard" },
 	{ STATS_OFFSET32(hw_csum_err),
 				4, STATS_FLAGS_BOTH, "rx_csum_offload_errors" },
-
+	{ STATS_OFFSET32(driver_xoff),
+				4, STATS_FLAGS_BOTH, "tx_exhaustion_events" },
 	{ STATS_OFFSET32(total_bytes_transmitted_hi),
 				8, STATS_FLAGS_BOTH, "tx_bytes" },
 	{ STATS_OFFSET32(tx_stat_ifhcoutbadoctets_hi),
-- 
1.9.3
