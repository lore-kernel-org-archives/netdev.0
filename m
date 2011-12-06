From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2x: Fix compile errors if CONFIG_CNIC is
 not set
Date: Tue, 6 Dec 2011 12:58:08 -0800
Message-ID: <1323205088-29693-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, barak@broadcom.com, eilong@broadcom.com,
	eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4469 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753382Ab1LFUwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 15:52:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't provide FCoE and iSCSI statistics to management firmware if
CONFIG_CNIC is not set.  Some needed structure fields are not defined
without CONFIG_CNIC.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 86d36f8..418e7d3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2943,6 +2943,7 @@ static void bnx2x_drv_info_ether_stat(struct bnx2x *bp)
 
 static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 {
+#ifdef BCM_CNIC
 	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
 	struct fcoe_stats_info *fcoe_stat =
 		&bp->slowpath->drv_info_to_mcp.fcoe_stat;
@@ -3026,7 +3027,6 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 		       fcoe_q_xstorm_stats->mcast_pkts_sent);
 	}
 
-#ifdef BCM_CNIC
 	/* ask L5 driver to add data to the struct */
 	bnx2x_cnic_notify(bp, CNIC_CTL_FCOE_STATS_GET_CMD);
 #endif
@@ -3034,6 +3034,7 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 
 static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)
 {
+#ifdef BCM_CNIC
 	struct bnx2x_dcbx_app_params *app = &bp->dcbx_port_params.app;
 	struct iscsi_stats_info *iscsi_stat =
 		&bp->slowpath->drv_info_to_mcp.iscsi_stat;
@@ -3043,7 +3044,6 @@ static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)
 	iscsi_stat->qos_priority =
 		app->traffic_type_priority[LLFC_TRAFFIC_TYPE_ISCSI];
 
-#ifdef BCM_CNIC
 	/* ask L5 driver to add data to the struct */
 	bnx2x_cnic_notify(bp, CNIC_CTL_ISCSI_STATS_GET_CMD);
 #endif
-- 
1.7.1
