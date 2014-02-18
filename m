From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/8] cxgb4: Allow >10G ports to have multiple queues
Date: Tue, 18 Feb 2014 17:56:10 +0530
Message-ID: <1392726375-32001-4-git-send-email-hariprasad@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755170AbaBRNgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:06 -0500
In-Reply-To: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Based on original work by Divy Le Ray.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5e345bc..1cc9b4d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5614,9 +5614,10 @@ static const struct pci_error_handlers cxgb4_eeh = {
 	.resume         = eeh_resume,
 };
 
-static inline bool is_10g_port(const struct link_config *lc)
+static inline bool is_x_10g_port(const struct link_config *lc)
 {
-	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0;
+	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0 ||
+	       (lc->supported & FW_PORT_CAP_SPEED_40G) != 0;
 }
 
 static inline void init_rspq(struct sge_rspq *q, u8 timer_idx, u8 pkt_cnt_idx,
@@ -5640,7 +5641,7 @@ static void cfg_queues(struct adapter *adap)
 	int i, q10g = 0, n10g = 0, qidx = 0;
 
 	for_each_port(adap, i)
-		n10g += is_10g_port(&adap2pinfo(adap, i)->link_cfg);
+		n10g += is_x_10g_port(&adap2pinfo(adap, i)->link_cfg);
 
 	/*
 	 * We default to 1 queue per non-10G port and up to # of cores queues
@@ -5655,7 +5656,7 @@ static void cfg_queues(struct adapter *adap)
 		struct port_info *pi = adap2pinfo(adap, i);
 
 		pi->first_qset = qidx;
-		pi->nqsets = is_10g_port(&pi->link_cfg) ? q10g : 1;
+		pi->nqsets = is_x_10g_port(&pi->link_cfg) ? q10g : 1;
 		qidx += pi->nqsets;
 	}
 
-- 
1.8.0
