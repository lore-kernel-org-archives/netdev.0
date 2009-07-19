From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivers/net/mlx4: Adjust constant
Date: Sun, 19 Jul 2009 18:09:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907191809050.16542@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754718AbZGSQJa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The values in the advertising field are typically ADVERTISED_xxx, not
SUPPORTED_xxx.  Both SUPPORTED_10000baseT_Full and
ADVERTISED_1000baseT_Full have the same value.

The semantic match that finds this problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
struct ethtool_cmd E;
@@
*E.advertising = SUPPORTED_10000baseT_Full
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/mlx4/en_ethtool.c       |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 091f990..86467b4 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -220,7 +220,7 @@ static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->autoneg = AUTONEG_DISABLE;
 	cmd->supported = SUPPORTED_10000baseT_Full;
-	cmd->advertising = SUPPORTED_10000baseT_Full;
+	cmd->advertising = ADVERTISED_1000baseT_Full;
 	if (netif_carrier_ok(dev)) {
 		cmd->speed = SPEED_10000;
 		cmd->duplex = DUPLEX_FULL;
