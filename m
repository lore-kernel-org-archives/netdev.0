From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] net: ethernet: mvneta: Remove IFF_UNICAST_FLT which is not implemented
Date: Thu, 24 Nov 2016 00:08:13 +0100
Message-ID: <1479942493-19784-1-git-send-email-andrew@lunn.ch>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53408 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWXJK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 18:09:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvneta driver advertises it supports IFF_UNICAST_FLT. However, it
actually does not. The hardware probably does support it, but there is
no code to configure the filter. As a quick and simple fix, remove the
flag. This will cause the core to fall back to promiscuous mode.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: b50b72de2f2f ("net: mvneta: enable features before registering the driver")
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5cb07c2017bf..0c0a45af950f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4151,7 +4151,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
-	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
 
 	err = register_netdev(dev);
-- 
2.10.2
