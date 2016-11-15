From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 13/15] net: ethernet: lantiq_etop: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:42 -0800
Message-ID: <20161115180644.3941-14-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        Jarod Wilson <jarod@redhat.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/lantiq_etop.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 1a739d71f1c2..9d931373a9b9 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -303,15 +303,9 @@ ltq_etop_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
-static int
-ltq_etop_nway_reset(struct net_device *dev)
-{
-	return phy_start_aneg(dev->phydev);
-}
-
 static const struct ethtool_ops ltq_etop_ethtool_ops = {
 	.get_drvinfo = ltq_etop_get_drvinfo,
-	.nway_reset = ltq_etop_nway_reset,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
-- 
2.9.3
