From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 29/52] sfc: Implement get_sset_count, replacing get_stats_count and self_test_count
Date: Mon, 1 Sep 2008 12:48:12 +0100
Message-ID: <20080901114811.GW7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60531 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759629AbYIALsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:48:14 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 72a2eb2..906d18a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -373,16 +373,18 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	return n;
 }
 
-static int efx_ethtool_get_stats_count(struct net_device *net_dev)
+static int efx_ethtool_get_sset_count(struct net_device *net_dev,
+				      int string_set)
 {
-	return EFX_ETHTOOL_NUM_STATS;
-}
-
-static int efx_ethtool_self_test_count(struct net_device *net_dev)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-
-	return efx_ethtool_fill_self_tests(efx, NULL, NULL, NULL);
+	switch (string_set) {
+	case ETH_SS_STATS:
+		return EFX_ETHTOOL_NUM_STATS;
+	case ETH_SS_TEST:
+		return efx_ethtool_fill_self_tests(netdev_priv(net_dev),
+						   NULL, NULL, NULL);
+	default:
+		return -EINVAL;
+	}
 }
 
 static void efx_ethtool_get_strings(struct net_device *net_dev,
@@ -719,10 +721,9 @@ struct ethtool_ops efx_ethtool_ops = {
 	.set_tso		= ethtool_op_set_tso,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
-	.self_test_count	= efx_ethtool_self_test_count,
+	.get_sset_count		= efx_ethtool_get_sset_count,
 	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
 	.phys_id		= efx_ethtool_phys_id,
-	.get_stats_count	= efx_ethtool_get_stats_count,
 	.get_ethtool_stats	= efx_ethtool_get_stats,
 };
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

