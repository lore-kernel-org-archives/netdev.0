From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4: Read stats for only available channels
Date: Tue,  7 Jul 2015 21:49:20 +0530
Message-ID: <1436285961-8674-4-git-send-email-hariprasad@chelsio.com>
References: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20776 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756740AbbGGLFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 07:05:36 -0400
In-Reply-To: <1436285961-8674-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updating the driver to read the stats of only available channels. T6 and
later has only 2 channels

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 73 +++++++++++-------------------
 1 file changed, 26 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index ba2be1e..1e6597d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3926,43 +3926,25 @@ void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
  */
 void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
 {
-	/* T6 and later has 2 channels */
-	if (adap->params.arch.nchan == NCHAN) {
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->mac_in_errs, 12, TP_MIB_MAC_IN_ERR_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tnl_cong_drops, 8,
-				 TP_MIB_TNL_CNG_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tnl_tx_drops, 4,
-				 TP_MIB_TNL_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->ofld_vlan_drops, 4,
-				 TP_MIB_OFD_VLN_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tcp6_in_errs, 4,
-				 TP_MIB_TCP_V6IN_ERR_0_A);
-	} else {
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->mac_in_errs, 2, TP_MIB_MAC_IN_ERR_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->hdr_in_errs, 2, TP_MIB_HDR_IN_ERR_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tcp_in_errs, 2, TP_MIB_TCP_IN_ERR_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tnl_cong_drops, 2,
-				 TP_MIB_TNL_CNG_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->ofld_chan_drops, 2,
-				 TP_MIB_OFD_CHN_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tnl_tx_drops, 2, TP_MIB_TNL_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->ofld_vlan_drops, 2,
-				 TP_MIB_OFD_VLN_DROP_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
-				 st->tcp6_in_errs, 2, TP_MIB_TCP_V6IN_ERR_0_A);
-	}
+	int nchan = adap->params.arch.nchan;
+
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->mac_in_errs, nchan, TP_MIB_MAC_IN_ERR_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->hdr_in_errs, nchan, TP_MIB_HDR_IN_ERR_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tcp_in_errs, nchan, TP_MIB_TCP_IN_ERR_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tnl_cong_drops, nchan, TP_MIB_TNL_CNG_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->ofld_chan_drops, nchan, TP_MIB_OFD_CHN_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tnl_tx_drops, nchan, TP_MIB_TNL_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->ofld_vlan_drops, nchan, TP_MIB_OFD_VLN_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tcp6_in_errs, nchan, TP_MIB_TCP_V6IN_ERR_0_A);
+
 	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
 			 &st->ofld_no_neigh, 2, TP_MIB_OFD_ARP_DROP_A);
 }
@@ -3976,16 +3958,13 @@ void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
  */
 void t4_tp_get_cpl_stats(struct adapter *adap, struct tp_cpl_stats *st)
 {
-	/* T6 and later has 2 channels */
-	if (adap->params.arch.nchan == NCHAN) {
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->req,
-				 8, TP_MIB_CPL_IN_REQ_0_A);
-	} else {
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->req,
-				 2, TP_MIB_CPL_IN_REQ_0_A);
-		t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->rsp,
-				 2, TP_MIB_CPL_OUT_RSP_0_A);
-	}
+	int nchan = adap->params.arch.nchan;
+
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->req,
+			 nchan, TP_MIB_CPL_IN_REQ_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A, st->rsp,
+			 nchan, TP_MIB_CPL_OUT_RSP_0_A);
+
 }
 
 /**
-- 
2.3.4
