From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 8/8] nfp: improve defines for constants in ethtool
Date: Thu,  2 Nov 2017 01:31:36 -0700
Message-ID: <20171102083136.2096-9-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:52236 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755440AbdKBIc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:29 -0400
Received: by mail-pf0-f193.google.com with SMTP id e64so4043646pfk.9
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:29 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We split rvector stats into two categories - per queue and
stats which are added up into one total counter.  Improve
the defines denoting their number.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 6d5c376f0000..c67b90c8d8b7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -181,7 +181,8 @@ static const struct nfp_et_stat nfp_mac_et_stats[] = {
 
 #define NN_ET_GLOBAL_STATS_LEN ARRAY_SIZE(nfp_net_et_stats)
 #define NN_ET_SWITCH_STATS_LEN 9
-#define NN_ET_RVEC_GATHER_STATS 8
+#define NN_RVEC_GATHER_STATS	8
+#define NN_RVEC_PER_Q_STATS	3
 
 static void nfp_net_get_nspinfo(struct nfp_app *app, char *version)
 {
@@ -427,7 +428,7 @@ static unsigned int nfp_vnic_get_sw_stats_count(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	return NN_ET_RVEC_GATHER_STATS + nn->dp.num_r_vecs * 3;
+	return NN_RVEC_GATHER_STATS + nn->dp.num_r_vecs * NN_RVEC_PER_Q_STATS;
 }
 
 static u8 *nfp_vnic_get_sw_stats_strings(struct net_device *netdev, u8 *data)
@@ -455,9 +456,9 @@ static u8 *nfp_vnic_get_sw_stats_strings(struct net_device *netdev, u8 *data)
 
 static u64 *nfp_vnic_get_sw_stats(struct net_device *netdev, u64 *data)
 {
-	u64 gathered_stats[NN_ET_RVEC_GATHER_STATS] = {};
+	u64 gathered_stats[NN_RVEC_GATHER_STATS] = {};
 	struct nfp_net *nn = netdev_priv(netdev);
-	u64 tmp[NN_ET_RVEC_GATHER_STATS];
+	u64 tmp[NN_RVEC_GATHER_STATS];
 	unsigned int i, j;
 
 	for (i = 0; i < nn->dp.num_r_vecs; i++) {
@@ -482,13 +483,13 @@ static u64 *nfp_vnic_get_sw_stats(struct net_device *netdev, u64 *data)
 			tmp[7] = nn->r_vecs[i].tx_lso;
 		} while (u64_stats_fetch_retry(&nn->r_vecs[i].tx_sync, start));
 
-		data += 3;
+		data += NN_RVEC_PER_Q_STATS;
 
-		for (j = 0; j < NN_ET_RVEC_GATHER_STATS; j++)
+		for (j = 0; j < NN_RVEC_GATHER_STATS; j++)
 			gathered_stats[j] += tmp[j];
 	}
 
-	for (j = 0; j < NN_ET_RVEC_GATHER_STATS; j++)
+	for (j = 0; j < NN_RVEC_GATHER_STATS; j++)
 		*data++ = gathered_stats[j];
 
 	return data;
-- 
2.14.1
