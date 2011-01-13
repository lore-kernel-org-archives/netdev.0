From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] ks8695net: Use default implementation of
 ethtool_ops::get_link
Date: Thu, 13 Jan 2011 17:52:51 +0000
Message-ID: <1294941171.3946.49.camel@bwh-desktop>
References: <1294941014.3946.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Figo.zhang" <figo1802@gmail.com>, zeal <zealcook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40930 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756934Ab1AMRwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 12:52:54 -0500
In-Reply-To: <1294941014.3946.46.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is completely untested as I don't have an ARM build environment.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I'm fairly confident that this is right for the WAN mode.  It depends on
the previous patch.

Ben.

 drivers/net/arm/ks8695net.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 8820fcd..62d6f88 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -994,20 +994,6 @@ ks8695_wan_nwayreset(struct net_device *ndev)
 }
 
 /**
- *	ks8695_wan_get_link - Retrieve link status of network interface
- *	@ndev: The network interface to retrive the link status of.
- */
-static u32
-ks8695_wan_get_link(struct net_device *ndev)
-{
-	struct ks8695_priv *ksp = netdev_priv(ndev);
-	u32 ctrl;
-
-	ctrl = readl(ksp->phyiface_regs + KS8695_WMC);
-	return ctrl & WMC_WLS;
-}
-
-/**
  *	ks8695_wan_get_pause - Retrieve network pause/flow-control
advertising
  *	@ndev: The device to retrieve settings from
  *	@param: The structure to fill out with the information
@@ -1058,7 +1044,7 @@ static const struct ethtool_ops
ks8695_wan_ethtool_ops = {
 	.get_settings	= ks8695_wan_get_settings,
 	.set_settings	= ks8695_wan_set_settings,
 	.nway_reset	= ks8695_wan_nwayreset,
-	.get_link	= ks8695_wan_get_link,
+	.get_link	= ethtool_op_get_link,
 	.get_pauseparam = ks8695_wan_get_pause,
 	.get_drvinfo	= ks8695_get_drvinfo,
 };
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

