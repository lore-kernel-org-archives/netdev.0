From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: [PATCH v2 12/26] IB: Convert ib_dma_*_coherent() argument type from u64 into dma_addr_t
Date: Thu, 12 Jan 2017 11:07:04 -0800
Message-ID: <20170112190718.6728-13-bart.vanassche@sandisk.com>
References: <20170112190718.6728-1-bart.vanassche@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rds-devel@oss.oracle.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112190718.6728-1-bart.vanassche@sandisk.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch does not change any functionality.

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-rdma@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: rds-devel@oss.oracle.com
---
 include/rdma/ib_verbs.h | 11 +++--------
 net/rds/ib.h            |  6 +++---
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 89e80eb77e06..de8dfb61d2b6 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -3109,15 +3109,10 @@ static inline void ib_dma_sync_single_for_device(struct ib_device *dev,
  */
 static inline void *ib_dma_alloc_coherent(struct ib_device *dev,
 					   size_t size,
-					   u64 *dma_handle,
+					   dma_addr_t *dma_handle,
 					   gfp_t flag)
 {
-	dma_addr_t handle;
-	void *ret;
-
-	ret = dma_alloc_coherent(dev->dma_device, size, &handle, flag);
-	*dma_handle = handle;
-	return ret;
+	return dma_alloc_coherent(dev->dma_device, size, dma_handle, flag);
 }
 
 /**
@@ -3129,7 +3124,7 @@ static inline void *ib_dma_alloc_coherent(struct ib_device *dev,
  */
 static inline void ib_dma_free_coherent(struct ib_device *dev,
 					size_t size, void *cpu_addr,
-					u64 dma_handle)
+					dma_addr_t dma_handle)
 {
 	dma_free_coherent(dev->dma_device, size, cpu_addr, dma_handle);
 }
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 45ac8e8e58f4..d21ca88ab628 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -134,7 +134,7 @@ struct rds_ib_connection {
 	struct rds_ib_work_ring	i_send_ring;
 	struct rm_data_op	*i_data_op;
 	struct rds_header	*i_send_hdrs;
-	u64			i_send_hdrs_dma;
+	dma_addr_t		i_send_hdrs_dma;
 	struct rds_ib_send_work *i_sends;
 	atomic_t		i_signaled_sends;
 
@@ -144,7 +144,7 @@ struct rds_ib_connection {
 	struct rds_ib_incoming	*i_ibinc;
 	u32			i_recv_data_rem;
 	struct rds_header	*i_recv_hdrs;
-	u64			i_recv_hdrs_dma;
+	dma_addr_t		i_recv_hdrs_dma;
 	struct rds_ib_recv_work *i_recvs;
 	u64			i_ack_recv;	/* last ACK received */
 	struct rds_ib_refill_cache i_cache_incs;
@@ -161,7 +161,7 @@ struct rds_ib_connection {
 	struct rds_header	*i_ack;
 	struct ib_send_wr	i_ack_wr;
 	struct ib_sge		i_ack_sge;
-	u64			i_ack_dma;
+	dma_addr_t		i_ack_dma;
 	unsigned long		i_ack_queued;
 
 	/* Flow control related information
-- 
2.11.0
