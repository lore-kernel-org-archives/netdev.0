From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: bcm63xx_enet: fix build failure
Date: Wed, 16 Nov 2016 22:50:16 +0000
Message-ID: <1479336616-26500-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The build of mips bcm63xx_defconfig was failing with the error:
drivers/net/ethernet/broadcom/bcm63xx_enet.c:1440:2:
	error: expected expression before 'return'

The return statement should be termibated with ';' and not ','.

Fixes: 42469bf5d9bb ("net: bcm63xx_enet: Utilize phy_ethtool_nway_reset")
Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---

build log is at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/176269457

 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a43ab90..3b14d51 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1435,7 +1435,7 @@ static int bcm_enet_nway_reset(struct net_device *dev)
 
 	priv = netdev_priv(dev);
 	if (priv->has_phy)
-		return phy_ethtool_nway_reset(dev),
+		return phy_ethtool_nway_reset(dev);
 
 	return -EOPNOTSUPP;
 }
-- 
1.9.1
