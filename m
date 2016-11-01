From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/3] net: 3c59x: use new api ethtool_{get|set}_link_ksettings
Date: Tue,  1 Nov 2016 16:32:26 +0100
Message-ID: <1478014347-14994-2-git-send-email-tremyfr@gmail.com>
References: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: klassert@mathematik.tu-chemnitz.de, davem@davemloft.net,
        mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478014347-14994-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/3com/3c59x.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 3ecf613..b3560a3 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2907,18 +2907,20 @@ static int vortex_nway_reset(struct net_device *dev)
 	return mii_nway_restart(&vp->mii);
 }
 
-static int vortex_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int vortex_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 
-	return mii_ethtool_gset(&vp->mii, cmd);
+	return mii_ethtool_get_link_ksettings(&vp->mii, cmd);
 }
 
-static int vortex_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int vortex_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct vortex_private *vp = netdev_priv(dev);
 
-	return mii_ethtool_sset(&vp->mii, cmd);
+	return mii_ethtool_set_link_ksettings(&vp->mii, cmd);
 }
 
 static u32 vortex_get_msglevel(struct net_device *dev)
@@ -3031,13 +3033,13 @@ static int vortex_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	.set_msglevel           = vortex_set_msglevel,
 	.get_ethtool_stats      = vortex_get_ethtool_stats,
 	.get_sset_count		= vortex_get_sset_count,
-	.get_settings           = vortex_get_settings,
-	.set_settings           = vortex_set_settings,
 	.get_link               = ethtool_op_get_link,
 	.nway_reset             = vortex_nway_reset,
 	.get_wol                = vortex_get_wol,
 	.set_wol                = vortex_set_wol,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings     = vortex_get_link_ksettings,
+	.set_link_ksettings     = vortex_set_link_ksettings,
 };
 
 #ifdef CONFIG_PCI
-- 
1.7.4.4
