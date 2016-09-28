From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v1] mlx4: remove unused fields
Date: Wed, 28 Sep 2016 11:00:04 -0700
Message-ID: <1475085604-101493-1-git-send-email-ddecotig@gmail.com>
Cc: edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

This also can address following UBSAN warnings:
[   36.640343] ================================================================================
[   36.648772] UBSAN: Undefined behaviour in drivers/net/ethernet/mellanox/mlx4/fw.c:857:26
[   36.656853] shift exponent 64 is too large for 32-bit type 'int'
[   36.663348] ================================================================================
[   36.671783] ================================================================================
[   36.680213] UBSAN: Undefined behaviour in drivers/net/ethernet/mellanox/mlx4/fw.c:861:27
[   36.688297] shift exponent 35 is too large for 32-bit type 'int'
[   36.694702] ================================================================================

Tested:
  reboot with UBSAN, no warning.

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 4 ----
 drivers/net/ethernet/mellanox/mlx4/fw.h | 2 --
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 090bf81..f9cbc67 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -853,12 +853,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_eqs = 1 << (field & 0xf);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_MTT_OFFSET);
 	dev_cap->reserved_mtts = 1 << (field >> 4);
-	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MRW_SZ_OFFSET);
-	dev_cap->max_mrw_sz = 1 << field;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_MRW_OFFSET);
 	dev_cap->reserved_mrws = 1 << (field & 0xf);
-	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MTT_SEG_OFFSET);
-	dev_cap->max_mtt_seg = 1 << (field & 0x3f);
 	MLX4_GET(size, outbox, QUERY_DEV_CAP_NUM_SYS_EQ_OFFSET);
 	dev_cap->num_sys_eqs = size & 0xfff;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_REQ_QP_OFFSET);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index f11614f..5343a05 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -80,9 +80,7 @@ struct mlx4_dev_cap {
 	int max_eqs;
 	int num_sys_eqs;
 	int reserved_mtts;
-	int max_mrw_sz;
 	int reserved_mrws;
-	int max_mtt_seg;
 	int max_requester_per_qp;
 	int max_responder_per_qp;
 	int max_rdma_global;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
