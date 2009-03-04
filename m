From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/7] sfc: Fix efx_ethtool_nway_result() to use clause 45
	MDIO registers
Date: Wed, 04 Mar 2009 19:51:12 +0000
Message-ID: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:53955 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756009AbZCDTvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 14:51:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7b5924c..589d132 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -529,7 +529,14 @@ static int efx_ethtool_nway_reset(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	return mii_nway_restart(&efx->mii);
+	if (efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) {
+		mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_AN,
+				       MDIO_MMDREG_CTRL1,
+				       __ffs(BMCR_ANRESTART), true);
+		return 0;
+	}
+
+	return -EOPNOTSUPP;
 }
 
 static u32 efx_ethtool_get_link(struct net_device *net_dev)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

