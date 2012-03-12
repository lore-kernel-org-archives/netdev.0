From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 4/8] bnx2x: use param's id instead of sp_obj's id
Date: Mon, 12 Mar 2012 14:53:10 -0400
Message-ID: <1331578394-1153-5-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3987 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695Ab2CLL72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:28 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, we've used the object's function id instead of using the
input's value. This is remedied, as in other flows.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h   |    3 +++
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b4afef6..bf14a08 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2800,6 +2800,7 @@ static void bnx2x_pf_rx_q_prep(struct bnx2x *bp,
 	rxq_init->sge_buf_sz = sge_sz;
 	rxq_init->max_sges_pkt = max_sge;
 	rxq_init->rss_engine_id = BP_FUNC(bp);
+	rxq_init->mcast_engine_id = BP_FUNC(bp);
 
 	/* Maximum number or simultaneous TPA aggregation for this Queue.
 	 *
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index f913cdd..1999fa5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4473,7 +4473,7 @@ static void bnx2x_q_fill_init_rx_data(struct bnx2x_queue_sp_obj *o,
 	rx_data->is_leading_rss = test_bit(BNX2X_Q_FLG_LEADING_RSS, flags);
 
 	if (test_bit(BNX2X_Q_FLG_MCAST, flags)) {
-		rx_data->approx_mcast_engine_id = o->func_id;
+		rx_data->approx_mcast_engine_id = params->mcast_engine_id;
 		rx_data->is_approx_mcast = 1;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 0be63e7..4ce351b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -897,6 +897,9 @@ struct bnx2x_rxq_setup_params {
 	u8		max_tpa_queues;
 	u8		rss_engine_id;
 
+	/* valid iff BNX2X_Q_FLG_MCAST */
+	u8		mcast_engine_id;
+
 	u8		cache_line_log;
 
 	u8		sb_cq_index;
-- 
1.7.9.rc2
