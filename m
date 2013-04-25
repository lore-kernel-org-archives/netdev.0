From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] net: calxedaxgmac: fix condition in
 xgmac_set_features()
Date: Thu, 25 Apr 2013 10:44:20 +0300
Message-ID: <20130425074420.GA11880@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	kernel-janitors@vger.kernel.org
To: Grant Likely <grant.likely@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39558 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab3DYHoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:44:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "changed" variable should be a 64 bit type, otherwise it can't store
all the features.  The way the code is now the test for whether
NETIF_F_RXCSUM changed is always false and we return immediately.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 791e5ff..4a1f2fa 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1482,7 +1482,7 @@ static int xgmac_set_features(struct net_device *dev, netdev_features_t features
 	u32 ctrl;
 	struct xgmac_priv *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->base;
-	u32 changed = dev->features ^ features;
+	netdev_features_t changed = dev->features ^ features;
 
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
