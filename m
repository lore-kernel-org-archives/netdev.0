From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next v2 1/6] tg3: Remove ethtool stats member from
 dev struct
Date: Thu, 8 Dec 2011 16:40:13 -0800
Message-ID: <1323391218-32241-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2673 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737Ab1LIAjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 19:39:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the ethtool stats member from the tg3 device
structure.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   14 +++++++-------
 drivers/net/ethernet/broadcom/tg3.h |    1 -
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cf36312..26eb4d4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9770,7 +9770,8 @@ err_out1:
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *,
 						 struct rtnl_link_stats64 *);
-static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *);
+static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *,
+						struct tg3_ethtool_stats *);
 
 static int tg3_close(struct net_device *dev)
 {
@@ -9804,9 +9805,7 @@ static int tg3_close(struct net_device *dev)
 	tg3_ints_fini(tp);
 
 	tg3_get_stats64(tp->dev, &tp->net_stats_prev);
-
-	memcpy(&tp->estats_prev, tg3_get_estats(tp),
-	       sizeof(tp->estats_prev));
+	tg3_get_estats(tp, &tp->estats_prev);
 
 	tg3_napi_fini(tp);
 
@@ -9854,9 +9853,9 @@ static u64 calc_crc_errors(struct tg3 *tp)
 	estats->member =	old_estats->member + \
 				get_stat64(&hw_stats->member)
 
-static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp)
+static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp,
+					       struct tg3_ethtool_stats *estats)
 {
-	struct tg3_ethtool_stats *estats = &tp->estats;
 	struct tg3_ethtool_stats *old_estats = &tp->estats_prev;
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
@@ -10762,7 +10761,8 @@ static void tg3_get_ethtool_stats(struct net_device *dev,
 				   struct ethtool_stats *estats, u64 *tmp_stats)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	memcpy(tmp_stats, tg3_get_estats(tp), sizeof(tp->estats));
+
+	tg3_get_estats(tp, (struct tg3_ethtool_stats *)tmp_stats);
 }
 
 static __be32 *tg3_vpd_readblock(struct tg3 *tp, u32 *vpdlen)
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 9cc10a8..a2818ef 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3013,7 +3013,6 @@ struct tg3 {
 	unsigned long			rx_dropped;
 	unsigned long			tx_dropped;
 	struct rtnl_link_stats64	net_stats_prev;
-	struct tg3_ethtool_stats	estats;
 	struct tg3_ethtool_stats	estats_prev;
 
 	DECLARE_BITMAP(tg3_flags, TG3_FLAG_NUMBER_OF_FLAGS);
-- 
1.7.3.4
