From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/6] cxgb4: Issue mbox commands on correct mbox
Date: Tue, 12 Aug 2014 11:09:13 +0530
Message-ID: <1407821953-8711-7-git-send-email-hariprasad@chelsio.com>
References: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43206
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752455AbaHLFdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 01:33:47 -0400
In-Reply-To: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 684ada0..66b762a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5959,7 +5959,8 @@ static int adap_init0(struct adapter *adap)
 		params[3] = FW_PARAM_PFVF(CQ_END);
 		params[4] = FW_PARAM_PFVF(OCQ_START);
 		params[5] = FW_PARAM_PFVF(OCQ_END);
-		ret = t4_query_params(adap, 0, 0, 0, 6, params, val);
+		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 6, params,
+				      val);
 		if (ret < 0)
 			goto bye;
 		adap->vres.qp.start = val[0];
@@ -5971,7 +5972,8 @@ static int adap_init0(struct adapter *adap)
 
 		params[0] = FW_PARAM_DEV(MAXORDIRD_QP);
 		params[1] = FW_PARAM_DEV(MAXIRD_ADAPTER);
-		ret = t4_query_params(adap, 0, 0, 0, 2, params, val);
+		ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params,
+				      val);
 		if (ret < 0) {
 			adap->params.max_ordird_qp = 8;
 			adap->params.max_ird_adapter = 32 * adap->tids.ntids;
-- 
1.7.1
