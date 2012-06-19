From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 09/14] Fix chelsio/cxgb4
Date: Tue, 19 Jun 2012 18:14:03 +0300
Message-ID: <1340118848-30978-10-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Divy Le Ray" <divy@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4211 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908Ab2FSPQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:37 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Divy Le Ray <divy@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e1f96fb..4a70867 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3482,7 +3482,7 @@ static inline void init_rspq(struct sge_rspq *q, u8 timer_idx, u8 pkt_cnt_idx,
 static void __devinit cfg_queues(struct adapter *adap)
 {
 	struct sge *s = &adap->sge;
-	int i, q10g = 0, n10g = 0, qidx = 0;
+	int i, q10g = 0, n10g = 0, qidx = 0, ncpu;
 
 	for_each_port(adap, i)
 		n10g += is_10g_port(&adap2pinfo(adap, i)->link_cfg);
@@ -3491,10 +3491,11 @@ static void __devinit cfg_queues(struct adapter *adap)
 	 * We default to 1 queue per non-10G port and up to # of cores queues
 	 * per 10G port.
 	 */
+	ncpu = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
 	if (n10g)
 		q10g = (MAX_ETH_QSETS - (adap->params.nports - n10g)) / n10g;
-	if (q10g > num_online_cpus())
-		q10g = num_online_cpus();
+	if (q10g > ncpu)
+		q10g = ncpu;
 
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
-- 
1.7.9.rc2
