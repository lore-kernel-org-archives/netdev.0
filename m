From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 6/8] cxgb4: Return error if setup_rss is called before probe
Date: Wed, 21 Oct 2015 14:39:55 +0530
Message-ID: <1445418597-771-7-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:17103 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754087AbbJUJKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:08 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index b7b8c46..59374dc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -1015,11 +1015,15 @@ static int set_rss_table(struct net_device *dev, const u32 *p, const u8 *key,
 	if (!p)
 		return 0;
 
-	for (i = 0; i < pi->rss_size; i++)
-		pi->rss[i] = p[i];
-	if (pi->adapter->flags & FULL_INIT_DONE)
+	/* Interface must be brought up atleast once */
+	if (pi->adapter->flags & FULL_INIT_DONE) {
+		for (i = 0; i < pi->rss_size; i++)
+			pi->rss[i] = p[i];
+
 		return cxgb4_write_rss(pi, pi->rss);
-	return 0;
+	}
+
+	return -EPERM;
 }
 
 static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
-- 
2.3.4
