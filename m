From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH v2 17/17] IB/Verbs: Move rdma_port_get_link_layer() to mlx4
 head file
Date: Tue, 07 Apr 2015 14:39:53 +0200
Message-ID: <5523D019.1060805@profitbricks.com>
References: <5523CCD5.6030401@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Mike Marciniszyn <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5523CCD5.6030401-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Now only mlx4 still using rdma_port_get_link_layer(), move it
to it's private head file.

Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
 drivers/infiniband/core/verbs.c      | 20 --------------------
 drivers/infiniband/hw/mlx4/mlx4_ib.h |  8 ++++++++
 include/rdma/ib_verbs.h              |  3 ---
 3 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index 49acdbc..f1eac93 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -107,26 +107,6 @@ __attribute_const__ int ib_rate_to_mbps(enum ib_rate rate)
 }
 EXPORT_SYMBOL(ib_rate_to_mbps);
 
-enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device, u8 port_num)
-{
-	if (device->get_link_layer)
-		return device->get_link_layer(device, port_num);
-
-	switch (device->query_transport(device, port_num)) {
-	case RDMA_TRANSPORT_IB:
-	case RDMA_TRANSPORT_IBOE:
-		return IB_LINK_LAYER_INFINIBAND;
-	case RDMA_TRANSPORT_IWARP:
-	case RDMA_TRANSPORT_USNIC:
-	case RDMA_TRANSPORT_USNIC_UDP:
-		return IB_LINK_LAYER_ETHERNET;
-	default:
-		BUG();
-		return IB_LINK_LAYER_UNSPECIFIED;
-	}
-}
-EXPORT_SYMBOL(rdma_port_get_link_layer);
-
 /* Protection domains */
 
 struct ib_pd *ib_alloc_pd(struct ib_device *device)
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 6eb743f..8e86ecc 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -708,6 +708,14 @@ int __mlx4_ib_query_pkey(struct ib_device *ibdev, u8 port, u16 index,
 int __mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index,
 			union ib_gid *gid, int netw_view);
 
+static enum rdma_link_layer
+rdma_port_get_link_layer(struct ib_device *device, u8 port_num)
+{
+	/* Will this happen? */
+	BUG_ON(!device->get_link_layer);
+	return device->get_link_layer(device, port_num);
+}
+
 static inline bool mlx4_ib_ah_grh_present(struct mlx4_ib_ah *ah)
 {
 	u8 port = be32_to_cpu(ah->av.ib.port_pd) >> 24 & 3;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index f033f824..67b3e71 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1742,9 +1742,6 @@ int ib_query_device(struct ib_device *device,
 int ib_query_port(struct ib_device *device,
 		  u8 port_num, struct ib_port_attr *port_attr);
 
-enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device,
-					       u8 port_num);
-
 static inline int rdma_transport_ib(struct ib_device *device, u8 port_num)
 {
 	return device->query_transport(device, port_num)
-- 
2.1.0
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
