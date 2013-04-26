From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net-next 2/3] be2net: Renamed rx_address_mismatch_errors to rx_address_filtered
Date: Fri, 26 Apr 2013 14:33:21 +0530
Message-ID: <78fd573c-b3d7-4782-bf83-c1fb34cd0ab5@CMEXHTCAS1.ad.emulex.com>
References: <1366967002-26811-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Suresh Reddy <suresh.reddy@emulex.com>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:26229 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754404Ab3DZJBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 05:01:37 -0400
In-Reply-To: <1366967002-26811-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   10 +++++-----
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    |   14 +++++++-------
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4b62e7f..9045903 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -293,7 +293,7 @@ struct be_drv_stats {
 	u32 rx_in_range_errors;
 	u32 rx_out_range_errors;
 	u32 rx_frame_too_long;
-	u32 rx_address_mismatch_drops;
+	u32 rx_address_filtered;
 	u32 rx_dropped_too_small;
 	u32 rx_dropped_too_short;
 	u32 rx_dropped_header_too_small;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 4d03789..0fc9b47 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -590,8 +590,8 @@ struct be_port_rxf_stats_v0 {
 	u32 rx_in_range_errors;	/* dword 10*/
 	u32 rx_out_range_errors;	/* dword 11*/
 	u32 rx_frame_too_long;	/* dword 12*/
-	u32 rx_address_mismatch_drops;	/* dword 13*/
-	u32 rx_vlan_mismatch_drops;	/* dword 14*/
+	u32 rx_address_filtered;	/* dword 13*/
+	u32 rx_vlan_filtered;	/* dword 14*/
 	u32 rx_dropped_too_small;	/* dword 15*/
 	u32 rx_dropped_too_short;	/* dword 16*/
 	u32 rx_dropped_header_too_small;	/* dword 17*/
@@ -797,8 +797,8 @@ struct lancer_pport_stats {
 	u32 rx_control_frames_unknown_opcode_hi;
 	u32 rx_in_range_errors;
 	u32 rx_out_of_range_errors;
-	u32 rx_address_mismatch_drops;
-	u32 rx_vlan_mismatch_drops;
+	u32 rx_address_filtered;
+	u32 rx_vlan_filtered;
 	u32 rx_dropped_too_small;
 	u32 rx_dropped_too_short;
 	u32 rx_dropped_header_too_small;
@@ -1576,7 +1576,7 @@ struct be_port_rxf_stats_v1 {
 	u32 rx_in_range_errors;
 	u32 rx_out_range_errors;
 	u32 rx_frame_too_long;
-	u32 rx_address_mismatch_drops;
+	u32 rx_address_filtered;
 	u32 rx_dropped_too_small;
 	u32 rx_dropped_too_short;
 	u32 rx_dropped_header_too_small;
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index ac05bbe..c4662db 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -54,7 +54,7 @@ static const struct be_ethtool_stat et_stats[] = {
 	/* Received packets dropped when they don't pass the unicast or
 	 * multicast address filtering.
 	 */
-	{DRVSTAT_INFO(rx_address_mismatch_drops)},
+	{DRVSTAT_INFO(rx_address_filtered)},
 	/* Received packets dropped when IP packet length field is less than
 	 * the IP header length field.
 	 */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a8926eb..43d5c1e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -353,9 +353,9 @@ static void populate_be_v0_stats(struct be_adapter *adapter)
 	drvs->rx_input_fifo_overflow_drop = port_stats->rx_input_fifo_overflow;
 	drvs->rx_dropped_header_too_small =
 		port_stats->rx_dropped_header_too_small;
-	drvs->rx_address_mismatch_drops =
-					port_stats->rx_address_mismatch_drops +
-					port_stats->rx_vlan_mismatch_drops;
+	drvs->rx_address_filtered =
+					port_stats->rx_address_filtered +
+					port_stats->rx_vlan_filtered;
 	drvs->rx_alignment_symbol_errors =
 		port_stats->rx_alignment_symbol_errors;
 
@@ -404,7 +404,7 @@ static void populate_be_v1_stats(struct be_adapter *adapter)
 		port_stats->rx_dropped_header_too_small;
 	drvs->rx_input_fifo_overflow_drop =
 		port_stats->rx_input_fifo_overflow_drop;
-	drvs->rx_address_mismatch_drops = port_stats->rx_address_mismatch_drops;
+	drvs->rx_address_filtered = port_stats->rx_address_filtered;
 	drvs->rx_alignment_symbol_errors =
 		port_stats->rx_alignment_symbol_errors;
 	drvs->rxpp_fifo_overflow_drop = port_stats->rxpp_fifo_overflow_drop;
@@ -445,9 +445,9 @@ static void populate_lancer_stats(struct be_adapter *adapter)
 	drvs->rx_dropped_header_too_small =
 				pport_stats->rx_dropped_header_too_small;
 	drvs->rx_input_fifo_overflow_drop = pport_stats->rx_fifo_overflow;
-	drvs->rx_address_mismatch_drops =
-					pport_stats->rx_address_mismatch_drops +
-					pport_stats->rx_vlan_mismatch_drops;
+	drvs->rx_address_filtered =
+					pport_stats->rx_address_filtered +
+					pport_stats->rx_vlan_filtered;
 	drvs->rx_alignment_symbol_errors = pport_stats->rx_symbol_errors_lo;
 	drvs->rxpp_fifo_overflow_drop = pport_stats->rx_fifo_overflow;
 	drvs->tx_pauseframes = pport_stats->tx_pause_frames_lo;
-- 
1.7.9.5
