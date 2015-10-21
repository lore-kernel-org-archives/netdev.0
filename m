From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/8] cxgb4: Don't disallow turning off auto-negotiation
Date: Wed, 21 Oct 2015 14:39:51 +0530
Message-ID: <1445418597-771-3-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:13110 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754087AbbJUJKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:03 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For {1, 10, 40} Gb/s. Prohibiting turning off autonegotiation isn't anywhere
in the standard.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 1127642..1487c57 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -629,10 +629,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		cap = speed_to_caps(speed);
 
-		if (!(lc->supported & cap) ||
-		    (speed == 1000) ||
-		    (speed == 10000) ||
-		    (speed == 40000))
+		if (!(lc->supported & cap))
 			return -EINVAL;
 		lc->requested_speed = cap;
 		lc->advertising = 0;
-- 
2.3.4
