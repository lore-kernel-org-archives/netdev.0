From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 10/15] net: fs_enet: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:39 -0800
Message-ID: <20161115180644.3941-11-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        linuxppc-dev@lists.ozlabs.org (open list:FREESCALE SOC FS_ENET DRIVER),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 44f50e168703..34843c155420 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -807,11 +807,6 @@ static void fs_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs->version = 0;
 }
 
-static int fs_nway_reset(struct net_device *dev)
-{
-	return 0;
-}
-
 static u32 fs_get_msglevel(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -865,7 +860,7 @@ static int fs_set_tunable(struct net_device *dev,
 static const struct ethtool_ops fs_ethtool_ops = {
 	.get_drvinfo = fs_get_drvinfo,
 	.get_regs_len = fs_get_regs_len,
-	.nway_reset = fs_nway_reset,
+	.nway_reset = phy_ethtool_nway_reset,
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = fs_get_msglevel,
 	.set_msglevel = fs_set_msglevel,
-- 
2.9.3
