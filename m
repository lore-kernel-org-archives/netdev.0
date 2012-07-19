From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 1/4] net/mlx4: Move MAC_MASK to a common place
Date: Thu, 19 Jul 2012 11:33:49 +0300
Message-ID: <1342686832-21406-2-git-send-email-ogerlitz@mellanox.com>
References: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:43398 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751939Ab2GSIeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 04:34:01 -0400
In-Reply-To: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Define this macro is one common place instead of duplicating it over the code

Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    1 -
 drivers/net/ethernet/mellanox/mlx4/port.c          |    1 -
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +--
 include/linux/mlx4/driver.h                        |    2 ++
 5 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index dd6a77b..9d0b88e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -34,12 +34,12 @@
 #include <linux/kernel.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/mlx4/driver.h>
 
 #include "mlx4_en.h"
 #include "en_port.h"
 
 #define EN_ETHTOOL_QP_ATTACH (1ull << 63)
-#define EN_ETHTOOL_MAC_MASK 0xffffffffffffULL
 #define EN_ETHTOOL_SHORT_MASK cpu_to_be16(0xffff)
 #define EN_ETHTOOL_WORD_MASK  cpu_to_be32(0xffffffff)
 
@@ -751,7 +751,7 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 	struct ethhdr *eth_spec;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_spec_list *spec_l2;
-	__be64 mac_msk = cpu_to_be64(EN_ETHTOOL_MAC_MASK << 16);
+	__be64 mac_msk = cpu_to_be64(MLX4_MAC_MASK << 16);
 
 	err = mlx4_en_validate_flow(dev, cmd);
 	if (err)
@@ -761,7 +761,7 @@ static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
 	if (!spec_l2)
 		return -ENOMEM;
 
-	mac = priv->mac & EN_ETHTOOL_MAC_MASK;
+	mac = priv->mac & MLX4_MAC_MASK;
 	be_mac = cpu_to_be64(mac << 16);
 
 	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 5bac0df..4ec3835 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -41,7 +41,6 @@
 
 #define MGM_QPN_MASK       0x00FFFFFF
 #define MGM_BLCK_LB_BIT    30
-#define MLX4_MAC_MASK	   0xffffffffffffULL
 
 static const u8 zero_gid[16];	/* automatically initialized to 0 */
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index a51d1b9..028833f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -39,7 +39,6 @@
 #include "mlx4.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
-#define MLX4_MAC_MASK		0xffffffffffffULL
 
 #define MLX4_VLAN_VALID		(1u << 31)
 #define MLX4_VLAN_MASK		0xfff
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c3fa919..94ceddd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -41,13 +41,12 @@
 #include <linux/slab.h>
 #include <linux/mlx4/cmd.h>
 #include <linux/mlx4/qp.h>
+#include <linux/if_ether.h>
 
 #include "mlx4.h"
 #include "fw.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
-#define MLX4_MAC_MASK		0x7fffffffffffffffULL
-#define ETH_ALEN		6
 
 struct mac_res {
 	struct list_head list;
diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
index 5f1298b..8dc485f 100644
--- a/include/linux/mlx4/driver.h
+++ b/include/linux/mlx4/driver.h
@@ -37,6 +37,8 @@
 
 struct mlx4_dev;
 
+#define MLX4_MAC_MASK	   0xffffffffffffULL
+
 enum mlx4_dev_event {
 	MLX4_DEV_EVENT_CATASTROPHIC_ERROR,
 	MLX4_DEV_EVENT_PORT_UP,
-- 
1.7.1
