From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH v1 6/6] net: netcp: Adds missing statistics for K2L and K2E
Date: Thu, 23 Jul 2015 15:57:24 -0400
Message-ID: <1437681444-23109-7-git-send-email-w-kwok2@ti.com>
References: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:55252 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754101AbbGWT54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 15:57:56 -0400
In-Reply-To: <1437681444-23109-1-git-send-email-w-kwok2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the missing statistics for the host
and slave ports of the CPSW on K2L and K2E platforms.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c |  177 ++++++++++++++++++++++++++++++++-
 1 file changed, 174 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index aa33066..01a955c 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -872,7 +872,7 @@ static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 };
 
 /* This is the size of entries in GBENU_STATS_HOST */
-#define GBENU_ET_STATS_HOST_SIZE	33
+#define GBENU_ET_STATS_HOST_SIZE	52
 
 #define GBENU_STATS_HOST(field)					\
 {								\
@@ -881,8 +881,8 @@ static const struct netcp_ethtool_stat gbe13_et_stats[] = {
 	offsetof(struct gbenu_hw_stats, field)			\
 }
 
-/* This is the size of entries in GBENU_STATS_HOST */
-#define GBENU_ET_STATS_PORT_SIZE	46
+/* This is the size of entries in GBENU_STATS_PORT */
+#define GBENU_ET_STATS_PORT_SIZE	65
 
 #define GBENU_STATS_P1(field)					\
 {								\
@@ -974,7 +974,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_HOST(ale_unknown_mcast_bytes),
 	GBENU_STATS_HOST(ale_unknown_bcast),
 	GBENU_STATS_HOST(ale_unknown_bcast_bytes),
+	GBENU_STATS_HOST(ale_pol_match),
+	GBENU_STATS_HOST(ale_pol_match_red),
+	GBENU_STATS_HOST(ale_pol_match_yellow),
 	GBENU_STATS_HOST(tx_mem_protect_err),
+	GBENU_STATS_HOST(tx_pri0_drop),
+	GBENU_STATS_HOST(tx_pri1_drop),
+	GBENU_STATS_HOST(tx_pri2_drop),
+	GBENU_STATS_HOST(tx_pri3_drop),
+	GBENU_STATS_HOST(tx_pri4_drop),
+	GBENU_STATS_HOST(tx_pri5_drop),
+	GBENU_STATS_HOST(tx_pri6_drop),
+	GBENU_STATS_HOST(tx_pri7_drop),
+	GBENU_STATS_HOST(tx_pri0_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri1_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri2_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri3_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri4_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri5_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri6_drop_bcnt),
+	GBENU_STATS_HOST(tx_pri7_drop_bcnt),
 	/* GBENU Module 1 */
 	GBENU_STATS_P1(rx_good_frames),
 	GBENU_STATS_P1(rx_broadcast_frames),
@@ -1021,7 +1040,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P1(ale_unknown_mcast_bytes),
 	GBENU_STATS_P1(ale_unknown_bcast),
 	GBENU_STATS_P1(ale_unknown_bcast_bytes),
+	GBENU_STATS_P1(ale_pol_match),
+	GBENU_STATS_P1(ale_pol_match_red),
+	GBENU_STATS_P1(ale_pol_match_yellow),
 	GBENU_STATS_P1(tx_mem_protect_err),
+	GBENU_STATS_P1(tx_pri0_drop),
+	GBENU_STATS_P1(tx_pri1_drop),
+	GBENU_STATS_P1(tx_pri2_drop),
+	GBENU_STATS_P1(tx_pri3_drop),
+	GBENU_STATS_P1(tx_pri4_drop),
+	GBENU_STATS_P1(tx_pri5_drop),
+	GBENU_STATS_P1(tx_pri6_drop),
+	GBENU_STATS_P1(tx_pri7_drop),
+	GBENU_STATS_P1(tx_pri0_drop_bcnt),
+	GBENU_STATS_P1(tx_pri1_drop_bcnt),
+	GBENU_STATS_P1(tx_pri2_drop_bcnt),
+	GBENU_STATS_P1(tx_pri3_drop_bcnt),
+	GBENU_STATS_P1(tx_pri4_drop_bcnt),
+	GBENU_STATS_P1(tx_pri5_drop_bcnt),
+	GBENU_STATS_P1(tx_pri6_drop_bcnt),
+	GBENU_STATS_P1(tx_pri7_drop_bcnt),
 	/* GBENU Module 2 */
 	GBENU_STATS_P2(rx_good_frames),
 	GBENU_STATS_P2(rx_broadcast_frames),
@@ -1068,7 +1106,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P2(ale_unknown_mcast_bytes),
 	GBENU_STATS_P2(ale_unknown_bcast),
 	GBENU_STATS_P2(ale_unknown_bcast_bytes),
+	GBENU_STATS_P2(ale_pol_match),
+	GBENU_STATS_P2(ale_pol_match_red),
+	GBENU_STATS_P2(ale_pol_match_yellow),
 	GBENU_STATS_P2(tx_mem_protect_err),
+	GBENU_STATS_P2(tx_pri0_drop),
+	GBENU_STATS_P2(tx_pri1_drop),
+	GBENU_STATS_P2(tx_pri2_drop),
+	GBENU_STATS_P2(tx_pri3_drop),
+	GBENU_STATS_P2(tx_pri4_drop),
+	GBENU_STATS_P2(tx_pri5_drop),
+	GBENU_STATS_P2(tx_pri6_drop),
+	GBENU_STATS_P2(tx_pri7_drop),
+	GBENU_STATS_P2(tx_pri0_drop_bcnt),
+	GBENU_STATS_P2(tx_pri1_drop_bcnt),
+	GBENU_STATS_P2(tx_pri2_drop_bcnt),
+	GBENU_STATS_P2(tx_pri3_drop_bcnt),
+	GBENU_STATS_P2(tx_pri4_drop_bcnt),
+	GBENU_STATS_P2(tx_pri5_drop_bcnt),
+	GBENU_STATS_P2(tx_pri6_drop_bcnt),
+	GBENU_STATS_P2(tx_pri7_drop_bcnt),
 	/* GBENU Module 3 */
 	GBENU_STATS_P3(rx_good_frames),
 	GBENU_STATS_P3(rx_broadcast_frames),
@@ -1115,7 +1172,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P3(ale_unknown_mcast_bytes),
 	GBENU_STATS_P3(ale_unknown_bcast),
 	GBENU_STATS_P3(ale_unknown_bcast_bytes),
+	GBENU_STATS_P3(ale_pol_match),
+	GBENU_STATS_P3(ale_pol_match_red),
+	GBENU_STATS_P3(ale_pol_match_yellow),
 	GBENU_STATS_P3(tx_mem_protect_err),
+	GBENU_STATS_P3(tx_pri0_drop),
+	GBENU_STATS_P3(tx_pri1_drop),
+	GBENU_STATS_P3(tx_pri2_drop),
+	GBENU_STATS_P3(tx_pri3_drop),
+	GBENU_STATS_P3(tx_pri4_drop),
+	GBENU_STATS_P3(tx_pri5_drop),
+	GBENU_STATS_P3(tx_pri6_drop),
+	GBENU_STATS_P3(tx_pri7_drop),
+	GBENU_STATS_P3(tx_pri0_drop_bcnt),
+	GBENU_STATS_P3(tx_pri1_drop_bcnt),
+	GBENU_STATS_P3(tx_pri2_drop_bcnt),
+	GBENU_STATS_P3(tx_pri3_drop_bcnt),
+	GBENU_STATS_P3(tx_pri4_drop_bcnt),
+	GBENU_STATS_P3(tx_pri5_drop_bcnt),
+	GBENU_STATS_P3(tx_pri6_drop_bcnt),
+	GBENU_STATS_P3(tx_pri7_drop_bcnt),
 	/* GBENU Module 4 */
 	GBENU_STATS_P4(rx_good_frames),
 	GBENU_STATS_P4(rx_broadcast_frames),
@@ -1162,7 +1238,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P4(ale_unknown_mcast_bytes),
 	GBENU_STATS_P4(ale_unknown_bcast),
 	GBENU_STATS_P4(ale_unknown_bcast_bytes),
+	GBENU_STATS_P4(ale_pol_match),
+	GBENU_STATS_P4(ale_pol_match_red),
+	GBENU_STATS_P4(ale_pol_match_yellow),
 	GBENU_STATS_P4(tx_mem_protect_err),
+	GBENU_STATS_P4(tx_pri0_drop),
+	GBENU_STATS_P4(tx_pri1_drop),
+	GBENU_STATS_P4(tx_pri2_drop),
+	GBENU_STATS_P4(tx_pri3_drop),
+	GBENU_STATS_P4(tx_pri4_drop),
+	GBENU_STATS_P4(tx_pri5_drop),
+	GBENU_STATS_P4(tx_pri6_drop),
+	GBENU_STATS_P4(tx_pri7_drop),
+	GBENU_STATS_P4(tx_pri0_drop_bcnt),
+	GBENU_STATS_P4(tx_pri1_drop_bcnt),
+	GBENU_STATS_P4(tx_pri2_drop_bcnt),
+	GBENU_STATS_P4(tx_pri3_drop_bcnt),
+	GBENU_STATS_P4(tx_pri4_drop_bcnt),
+	GBENU_STATS_P4(tx_pri5_drop_bcnt),
+	GBENU_STATS_P4(tx_pri6_drop_bcnt),
+	GBENU_STATS_P4(tx_pri7_drop_bcnt),
 	/* GBENU Module 5 */
 	GBENU_STATS_P5(rx_good_frames),
 	GBENU_STATS_P5(rx_broadcast_frames),
@@ -1209,7 +1304,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P5(ale_unknown_mcast_bytes),
 	GBENU_STATS_P5(ale_unknown_bcast),
 	GBENU_STATS_P5(ale_unknown_bcast_bytes),
+	GBENU_STATS_P5(ale_pol_match),
+	GBENU_STATS_P5(ale_pol_match_red),
+	GBENU_STATS_P5(ale_pol_match_yellow),
 	GBENU_STATS_P5(tx_mem_protect_err),
+	GBENU_STATS_P5(tx_pri0_drop),
+	GBENU_STATS_P5(tx_pri1_drop),
+	GBENU_STATS_P5(tx_pri2_drop),
+	GBENU_STATS_P5(tx_pri3_drop),
+	GBENU_STATS_P5(tx_pri4_drop),
+	GBENU_STATS_P5(tx_pri5_drop),
+	GBENU_STATS_P5(tx_pri6_drop),
+	GBENU_STATS_P5(tx_pri7_drop),
+	GBENU_STATS_P5(tx_pri0_drop_bcnt),
+	GBENU_STATS_P5(tx_pri1_drop_bcnt),
+	GBENU_STATS_P5(tx_pri2_drop_bcnt),
+	GBENU_STATS_P5(tx_pri3_drop_bcnt),
+	GBENU_STATS_P5(tx_pri4_drop_bcnt),
+	GBENU_STATS_P5(tx_pri5_drop_bcnt),
+	GBENU_STATS_P5(tx_pri6_drop_bcnt),
+	GBENU_STATS_P5(tx_pri7_drop_bcnt),
 	/* GBENU Module 6 */
 	GBENU_STATS_P6(rx_good_frames),
 	GBENU_STATS_P6(rx_broadcast_frames),
@@ -1256,7 +1370,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P6(ale_unknown_mcast_bytes),
 	GBENU_STATS_P6(ale_unknown_bcast),
 	GBENU_STATS_P6(ale_unknown_bcast_bytes),
+	GBENU_STATS_P6(ale_pol_match),
+	GBENU_STATS_P6(ale_pol_match_red),
+	GBENU_STATS_P6(ale_pol_match_yellow),
 	GBENU_STATS_P6(tx_mem_protect_err),
+	GBENU_STATS_P6(tx_pri0_drop),
+	GBENU_STATS_P6(tx_pri1_drop),
+	GBENU_STATS_P6(tx_pri2_drop),
+	GBENU_STATS_P6(tx_pri3_drop),
+	GBENU_STATS_P6(tx_pri4_drop),
+	GBENU_STATS_P6(tx_pri5_drop),
+	GBENU_STATS_P6(tx_pri6_drop),
+	GBENU_STATS_P6(tx_pri7_drop),
+	GBENU_STATS_P6(tx_pri0_drop_bcnt),
+	GBENU_STATS_P6(tx_pri1_drop_bcnt),
+	GBENU_STATS_P6(tx_pri2_drop_bcnt),
+	GBENU_STATS_P6(tx_pri3_drop_bcnt),
+	GBENU_STATS_P6(tx_pri4_drop_bcnt),
+	GBENU_STATS_P6(tx_pri5_drop_bcnt),
+	GBENU_STATS_P6(tx_pri6_drop_bcnt),
+	GBENU_STATS_P6(tx_pri7_drop_bcnt),
 	/* GBENU Module 7 */
 	GBENU_STATS_P7(rx_good_frames),
 	GBENU_STATS_P7(rx_broadcast_frames),
@@ -1303,7 +1436,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P7(ale_unknown_mcast_bytes),
 	GBENU_STATS_P7(ale_unknown_bcast),
 	GBENU_STATS_P7(ale_unknown_bcast_bytes),
+	GBENU_STATS_P7(ale_pol_match),
+	GBENU_STATS_P7(ale_pol_match_red),
+	GBENU_STATS_P7(ale_pol_match_yellow),
 	GBENU_STATS_P7(tx_mem_protect_err),
+	GBENU_STATS_P7(tx_pri0_drop),
+	GBENU_STATS_P7(tx_pri1_drop),
+	GBENU_STATS_P7(tx_pri2_drop),
+	GBENU_STATS_P7(tx_pri3_drop),
+	GBENU_STATS_P7(tx_pri4_drop),
+	GBENU_STATS_P7(tx_pri5_drop),
+	GBENU_STATS_P7(tx_pri6_drop),
+	GBENU_STATS_P7(tx_pri7_drop),
+	GBENU_STATS_P7(tx_pri0_drop_bcnt),
+	GBENU_STATS_P7(tx_pri1_drop_bcnt),
+	GBENU_STATS_P7(tx_pri2_drop_bcnt),
+	GBENU_STATS_P7(tx_pri3_drop_bcnt),
+	GBENU_STATS_P7(tx_pri4_drop_bcnt),
+	GBENU_STATS_P7(tx_pri5_drop_bcnt),
+	GBENU_STATS_P7(tx_pri6_drop_bcnt),
+	GBENU_STATS_P7(tx_pri7_drop_bcnt),
 	/* GBENU Module 8 */
 	GBENU_STATS_P8(rx_good_frames),
 	GBENU_STATS_P8(rx_broadcast_frames),
@@ -1350,7 +1502,26 @@ static const struct netcp_ethtool_stat gbenu_et_stats[] = {
 	GBENU_STATS_P8(ale_unknown_mcast_bytes),
 	GBENU_STATS_P8(ale_unknown_bcast),
 	GBENU_STATS_P8(ale_unknown_bcast_bytes),
+	GBENU_STATS_P8(ale_pol_match),
+	GBENU_STATS_P8(ale_pol_match_red),
+	GBENU_STATS_P8(ale_pol_match_yellow),
 	GBENU_STATS_P8(tx_mem_protect_err),
+	GBENU_STATS_P8(tx_pri0_drop),
+	GBENU_STATS_P8(tx_pri1_drop),
+	GBENU_STATS_P8(tx_pri2_drop),
+	GBENU_STATS_P8(tx_pri3_drop),
+	GBENU_STATS_P8(tx_pri4_drop),
+	GBENU_STATS_P8(tx_pri5_drop),
+	GBENU_STATS_P8(tx_pri6_drop),
+	GBENU_STATS_P8(tx_pri7_drop),
+	GBENU_STATS_P8(tx_pri0_drop_bcnt),
+	GBENU_STATS_P8(tx_pri1_drop_bcnt),
+	GBENU_STATS_P8(tx_pri2_drop_bcnt),
+	GBENU_STATS_P8(tx_pri3_drop_bcnt),
+	GBENU_STATS_P8(tx_pri4_drop_bcnt),
+	GBENU_STATS_P8(tx_pri5_drop_bcnt),
+	GBENU_STATS_P8(tx_pri6_drop_bcnt),
+	GBENU_STATS_P8(tx_pri7_drop_bcnt),
 };
 
 #define XGBE_STATS0_INFO(field)				\
-- 
1.7.9.5
