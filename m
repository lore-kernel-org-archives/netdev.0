From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 06/11] cxgb4: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:55 +0300
Message-ID: <1341148740-7375-7-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Divy Le Ray" <divy@chelsio.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3380 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282Ab2GANUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:41 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Divy Le Ray <divy@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e1f96fb..5ed49af 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3493,8 +3493,8 @@ static void __devinit cfg_queues(struct adapter *adap)
 	 */
 	if (n10g)
 		q10g = (MAX_ETH_QSETS - (adap->params.nports - n10g)) / n10g;
-	if (q10g > num_online_cpus())
-		q10g = num_online_cpus();
+	if (q10g > netif_get_num_default_rss_queues())
+		q10g = netif_get_num_default_rss_queues();
 
 	for_each_port(adap, i) {
 		struct port_info *pi = adap2pinfo(adap, i);
-- 
1.7.9.rc2
