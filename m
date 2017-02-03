From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] [net-next] net/mlx5e: fix another maybe-uninitialized false-positive
Date: Fri,  3 Feb 2017 17:37:03 +0100
Message-ID: <20170203163716.3501713-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Roi Dayan <roid-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Amir Vadai <amirva-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In commit abeffce ("net/mlx5e: Fix a -Wmaybe-uninitialized warning"), I fixed a
gcc warning for the ipv4 offload handling. Now we get the same warning for the
added ipv6 support:

drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:815:40: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]

We can apply the same workaround here as well.

Fixes: ce99f6b97fcd ("net/mlx5e: Support SRIOV TC encapsulation offloads for IPv6 tunnels")
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index e3cf5f484153..d87a82682cb5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -731,8 +731,8 @@ static int mlx5e_route_lookup_ipv6(struct mlx5e_priv *priv,
 	int ret;
 
 	dst = ip6_route_output(dev_net(mirred_dev), NULL, fl6);
-	if (dst->error) {
-		ret = dst->error;
+	ret = dst->error;
+	if (ret) {
 		dst_release(dst);
 		return ret;
 	}
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
