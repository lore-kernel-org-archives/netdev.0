From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 08/25] mlx4_core: fix buggy parsing of reserved eq cap
Date: Wed, 04 Nov 2009 17:30:52 +0200
Message-ID: <4AF19E2C.6060604@mellanox.co.il>
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


Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/fw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index a63f84a..87eb2d4 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -243,7 +243,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MPT_OFFSET);
 	dev_cap->max_mpts = 1 << (field & 0x3f);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_EQ_OFFSET);
-	dev_cap->reserved_eqs = 1 << (field & 0xf);
+	dev_cap->reserved_eqs = field & 0xf;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_EQ_OFFSET);
 	dev_cap->max_eqs = 1 << (field & 0xf);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_MTT_OFFSET);
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
