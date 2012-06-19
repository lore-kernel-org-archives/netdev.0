From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 12/14] Fix broadcom/tg3
Date: Tue, 19 Jun 2012 18:14:06 +0300
Message-ID: <1340118848-30978-13-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4114 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430Ab2FSPQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:53 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..d431f17 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9908,7 +9908,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	int i, rc;
 	struct msix_entry msix_ent[tp->irq_max];
 
-	tp->irq_cnt = num_online_cpus();
+	tp->irq_cnt = min_t(unsigned, num_online_cpus(),
+			    DEFAULT_MAX_NUM_RSS_QUEUES);
 	if (tp->irq_cnt > 1) {
 		/* We want as many rx rings enabled as there are cpus.
 		 * In multiqueue MSI-X mode, the first MSI-X vector
@@ -10967,7 +10968,8 @@ static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 		if (netif_running(tp->dev))
 			info->data = tp->irq_cnt;
 		else {
-			info->data = num_online_cpus();
+			info->data = min_t(u32, num_online_cpus(),
+					   DEFAULT_MAX_NUM_RSS_QUEUES);
 			if (info->data > TG3_IRQ_MAX_VECS_RSS)
 				info->data = TG3_IRQ_MAX_VECS_RSS;
 		}
-- 
1.7.9.rc2
