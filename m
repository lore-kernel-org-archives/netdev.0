From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] net/mlx4_en: Fix uninitialized use of 'port_up' in mlx4_en_set_channels()
Date: Sat, 17 May 2014 23:52:03 +0200
Message-ID: <1400363523-18371-1-git-send-email-cengelma@gmx.at>
Cc: amirv@mellanox.com, linux-kernel@vger.kernel.org,
	Christian Engelmayer <cengelma@gmx.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function mlx4_en_set_channels() stops running ports before performing the
requested action. In that case local variable 'port_up' is set so that the
port is restarted at the end of the function, however, in case the port was
not stopped, variable 'port_up' is left uninitialized and the behaviour is
undetermined. Detected by Coverity - CID 751497.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
Compile tested. Applies against branch master in tree
git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index a72d99f..7ba3df3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1121,7 +1121,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
-	int port_up;
+	int port_up = 0;
 	int err = 0;
 
 	if (channel->other_count || channel->combined_count ||
-- 
1.9.1
