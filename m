From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 3/4] net/mlx4_en: Implement ndo_gso_check()
Date: Thu, 13 Nov 2014 16:38:14 -0800
Message-ID: <1415925495-59312-4-git-send-email-joestringer@nicira.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
Cc: sathya.perla@emulex.com, shahed.shaikh@qlogic.com,
	amirv@mellanox.com, Dept-GELinuxNICDev@qlogic.com,
	therbert@google.com, gerlitz.or@gmail.com,
	alexander.duyck@gmail.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use vxlan_gso_check() to advertise offload support for this NIC.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Refactor out vxlan helper.
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 02266e3..c5fcc56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2355,6 +2355,11 @@ static void mlx4_en_del_vxlan_port(struct  net_device *dev,
 
 	queue_work(priv->mdev->workqueue, &priv->vxlan_del_task);
 }
+
+static bool mlx4_en_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	return vxlan_gso_check(skb);
+}
 #endif
 
 static const struct net_device_ops mlx4_netdev_ops = {
@@ -2386,6 +2391,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_MLX4_EN_VXLAN
 	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
 	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_gso_check		= mlx4_en_gso_check,
 #endif
 };
 
-- 
1.7.10.4
