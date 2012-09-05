From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: [V2 PATCH 9/9] cxgb4vf: Chelsio FCoE offload driver submission (header compatibility fixes).
Date: Wed,  5 Sep 2012 18:04:02 +0530
Message-ID: <1346848442-4573-10-git-send-email-naresh@chelsio.com>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
Cc: netdev@vger.kernel.org, naresh@chelsio.com, chethan@chelsio.com
To: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30537 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756109Ab2IEHBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 03:01:02 -0400
In-Reply-To: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains minor fixes to make cxgb4vf driver work with the updates to
shared firmware/hardware header files.

Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 8877fbf..33fc1ca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -536,7 +536,7 @@ static inline void ring_fl_db(struct adapter *adapter, struct sge_fl *fl)
 	if (fl->pend_cred >= FL_PER_EQ_UNIT) {
 		wmb();
 		t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
-			     DBPRIO |
+			     DBPRIO(1) |
 			     QID(fl->cntxt_id) |
 			     PIDX(fl->pend_cred / FL_PER_EQ_UNIT));
 		fl->pend_cred %= FL_PER_EQ_UNIT;
@@ -952,7 +952,7 @@ static inline void ring_tx_db(struct adapter *adapter, struct sge_txq *tq,
 	 * Warn if we write doorbells with the wrong priority and write
 	 * descriptors before telling HW.
 	 */
-	WARN_ON((QID(tq->cntxt_id) | PIDX(n)) & DBPRIO);
+	WARN_ON((QID(tq->cntxt_id) | PIDX(n)) & DBPRIO(1));
 	wmb();
 	t4_write_reg(adapter, T4VF_SGE_BASE_ADDR + SGE_VF_KDOORBELL,
 		     QID(tq->cntxt_id) | PIDX(n));
@@ -2126,8 +2126,8 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 		cmd.iqns_to_fl0congen =
 			cpu_to_be32(
 				FW_IQ_CMD_FL0HOSTFCMODE(SGE_HOSTFCMODE_NONE) |
-				FW_IQ_CMD_FL0PACKEN |
-				FW_IQ_CMD_FL0PADEN);
+				FW_IQ_CMD_FL0PACKEN(1) |
+				FW_IQ_CMD_FL0PADEN(1));
 		cmd.fl0dcaen_to_fl0cidxfthresh =
 			cpu_to_be16(
 				FW_IQ_CMD_FL0FBMIN(SGE_FETCHBURSTMIN_64B) |
@@ -2431,7 +2431,8 @@ int t4vf_sge_init(struct adapter *adapter)
 	 */
 	if (fl1)
 		FL_PG_ORDER = ilog2(fl1) - PAGE_SHIFT;
-	STAT_LEN = ((sge_params->sge_control & EGRSTATUSPAGESIZE) ? 128 : 64);
+	STAT_LEN = ((sge_params->sge_control & EGRSTATUSPAGESIZE(1)) ?
+		    128 : 64);
 	PKTSHIFT = PKTSHIFT_GET(sge_params->sge_control);
 	FL_ALIGN = 1 << (INGPADBOUNDARY_GET(sge_params->sge_control) +
 			 SGE_INGPADBOUNDARY_SHIFT);
-- 
1.7.1
