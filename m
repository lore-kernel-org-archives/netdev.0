From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 19/25 v2] mlx4: Randomizing mac addresses for slaves
Date: Fri, 06 Nov 2009 05:10:02 +0200
Message-ID: <4AF3938A.3080803@mellanox.co.il>
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
 drivers/net/mlx4/fw.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 60889d3..7343c70 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -32,6 +32,7 @@
  * SOFTWARE.
  */
 
+#include <linux/etherdevice.h>
 #include <linux/mlx4/cmd.h>
 #include <linux/cache.h>
 
@@ -148,7 +149,8 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 						       struct mlx4_cmd_mailbox *outbox)
 {
 	struct mlx4_caps *caps = outbox->buf;
-	int i;
+	u8 rand_mac[6];
+	int i, j;
 
 	memcpy(caps, &dev->caps, sizeof *caps);
 
@@ -165,6 +167,10 @@ int mlx4_QUERY_SLAVE_CAP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 		for (i = 1; i <= dev->caps.num_ports; ++i) {
 			caps->gid_table_len[i] = 1;
 			caps->pkey_table_len[i] = 1;
+			random_ether_addr(rand_mac);
+			caps->def_mac[i] = 0;
+			for (j = 0; j < ETH_ALEN; j++)
+				 caps->def_mac[i] |= ((u64)(rand_mac[1]) << 8 * j);
 		}
 	} else {
 		caps->sqp_demux = dev->num_slaves;
-- 
1.5.3.7

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
