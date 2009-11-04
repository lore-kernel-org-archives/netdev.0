From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Wed, 04 Nov 2009 17:31:53 +0200
Message-ID: <4AF19E69.8070605@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/fw.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 60889d3..9028592 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -32,6 +32,7 @@
  * SOFTWARE.
  */
 
+#include <linux/etherdevice.h>
 #include <linux/mlx4/cmd.h>
 #include <linux/cache.h>
 
@@ -148,6 +149,7 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 						       struct mlx4_cmd_mailbox *outbox)
 {
 	struct mlx4_caps *caps = outbox->buf;
+	u8 rand_mac[6];
 	int i;
 
 	memcpy(caps, &dev->caps, sizeof *caps);
@@ -165,6 +167,10 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 		for (i = 1; i <= dev->caps.num_ports; ++i) {
 			caps->gid_table_len[i] = 1;
 			caps->pkey_table_len[i] = 1;
+#define MLX4_MAC_HEAD		0x2c9000000ULL
+			random_ether_addr(rand_mac);
+			caps->def_mac[i] = MLX4_MAC_HEAD | rand_mac[0] |
+				((u64)(rand_mac[1]) << 8) | ((u64)(rand_mac[2]) << 16);
 		}
 	} else {
 		caps->sqp_demux = dev->num_slaves;
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
