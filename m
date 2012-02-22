From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 1/2] 3com/typhoon: reuse eth_mac_addr()
Date: Wed, 22 Feb 2012 13:36:38 +0100
Message-ID: <1329914199-30862-2-git-send-email-danny.kukawka@bisect.de>
References: <1329914199-30862-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:44643 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751599Ab2BVMgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 07:36:55 -0500
In-Reply-To: <1329914199-30862-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_mac_addr() for .ndo_set_mac_address, remove
typhoon_set_mac_address() since it do currently the same as
eth_mac_addr(). Additional advantage: eth_mac_addr() already
checks if the given address is valid.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/3com/typhoon.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index f7d622e..1234a14 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -966,18 +966,6 @@ typhoon_get_stats(struct net_device *dev)
 	return stats;
 }
 
-static int
-typhoon_set_mac_address(struct net_device *dev, void *addr)
-{
-	struct sockaddr *saddr = (struct sockaddr *) addr;
-
-	if(netif_running(dev))
-		return -EBUSY;
-
-	memcpy(dev->dev_addr, saddr->sa_data, dev->addr_len);
-	return 0;
-}
-
 static void
 typhoon_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
@@ -2266,7 +2254,7 @@ static const struct net_device_ops typhoon_netdev_ops = {
 	.ndo_tx_timeout		= typhoon_tx_timeout,
 	.ndo_get_stats		= typhoon_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= typhoon_set_mac_address,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
-- 
1.7.8.3
