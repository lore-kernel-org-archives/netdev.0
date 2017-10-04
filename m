From: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net v2] RDS: IB: Limit the scope of has_fr/has_fmr variables
Date: Wed,  4 Oct 2017 12:10:43 -0700
Message-ID: <1507144244-1611-1-git-send-email-avinash.repaka@oracle.com>
Cc: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fixes the scope of has_fr and has_fmr variables as they are
needed only in rds_ib_add_one().

Signed-off-by: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

---
 net/rds/ib.c | 11 ++++++-----
 net/rds/ib.h |  2 --
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index a0954ac..36dd209 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -126,6 +126,7 @@ void rds_ib_dev_put(struct rds_ib_device *rds_ibdev)
 static void rds_ib_add_one(struct ib_device *device)
 {
 	struct rds_ib_device *rds_ibdev;
+	bool has_fr, has_fmr;
 
 	/* Only handle IB (no iWARP) devices */
 	if (device->node_type != RDMA_NODE_IB_CA)
@@ -143,11 +144,11 @@ static void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_wrs = device->attrs.max_qp_wr;
 	rds_ibdev->max_sge = min(device->attrs.max_sge, RDS_IB_MAX_SGE);
 
-	rds_ibdev->has_fr = (device->attrs.device_cap_flags &
-				  IB_DEVICE_MEM_MGT_EXTENSIONS);
-	rds_ibdev->has_fmr = (device->alloc_fmr && device->dealloc_fmr &&
-			    device->map_phys_fmr && device->unmap_fmr);
-	rds_ibdev->use_fastreg = (rds_ibdev->has_fr && !rds_ibdev->has_fmr);
+	has_fr = (device->attrs.device_cap_flags &
+		  IB_DEVICE_MEM_MGT_EXTENSIONS);
+	has_fmr = (device->alloc_fmr && device->dealloc_fmr &&
+		   device->map_phys_fmr && device->unmap_fmr);
+	rds_ibdev->use_fastreg = (has_fr && !has_fmr);
 
 	rds_ibdev->fmr_max_remaps = device->attrs.max_map_per_fmr?: 32;
 	rds_ibdev->max_1m_mrs = device->attrs.max_mr ?
diff --git a/net/rds/ib.h b/net/rds/ib.h
index bf48224..6ea6a27 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -215,8 +215,6 @@ struct rds_ib_device {
 	struct list_head	conn_list;
 	struct ib_device	*dev;
 	struct ib_pd		*pd;
-	bool                    has_fmr;
-	bool                    has_fr;
 	bool                    use_fastreg;
 
 	unsigned int		max_mrs;
-- 
2.4.11

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
