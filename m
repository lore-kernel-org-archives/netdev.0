From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] rds: make local functions/variables static
Date: Tue, 19 Oct 2010 11:08:33 -0700
Message-ID: <20101019110833.7ef05180@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>,
	Zach Brown <zach.brown@oracle.com>,
	Chris Mason <chris.mason@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38923 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab0JSSIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Oct 2010 14:08:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RDS protocol has lots of functions that should be
declared static. rds_message_get/add_version_extension is
removed since it defined but never used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/rds/connection.c     |    2 +-
 net/rds/ib.c             |   10 +++++-----
 net/rds/ib.h             |    4 ----
 net/rds/ib_rdma.c        |    2 +-
 net/rds/ib_sysctl.c      |    2 +-
 net/rds/iw.c             |    4 ++--
 net/rds/iw.h             |    4 ----
 net/rds/iw_rdma.c        |    3 ++-
 net/rds/iw_sysctl.c      |    2 +-
 net/rds/message.c        |   24 ++----------------------
 net/rds/page.c           |    3 ++-
 net/rds/rdma_transport.c |    4 ++--
 net/rds/rdma_transport.h |    4 ----
 net/rds/rds.h            |    5 -----
 net/rds/recv.c           |    3 +--
 net/rds/send.c           |    4 +++-
 net/rds/tcp.c            |    6 +++---
 net/rds/tcp.h            |    2 --
 net/rds/tcp_recv.c       |    3 ++-
 net/rds/tcp_send.c       |    2 +-
 20 files changed, 29 insertions(+), 64 deletions(-)

--- a/net/rds/connection.c	2010-10-19 10:36:00.346844139 -0700
+++ b/net/rds/connection.c	2010-10-19 10:50:24.678156846 -0700
@@ -88,7 +88,7 @@ static struct rds_connection *rds_conn_l
  * and receiving over this connection again in the future.  It is up to
  * the transport to have serialized this call with its send and recv.
  */
-void rds_conn_reset(struct rds_connection *conn)
+static void rds_conn_reset(struct rds_connection *conn)
 {
 	rdsdebug("connection %pI4 to %pI4 reset\n",
 	  &conn->c_laddr, &conn->c_faddr);
--- a/net/rds/ib.c	2010-10-19 10:36:24.489145829 -0700
+++ b/net/rds/ib.c	2010-10-19 10:38:05.034732462 -0700
@@ -42,7 +42,7 @@
 #include "rds.h"
 #include "ib.h"
 
-unsigned int fmr_pool_size = RDS_FMR_POOL_SIZE;
+static unsigned int fmr_pool_size = RDS_FMR_POOL_SIZE;
 unsigned int fmr_message_size = RDS_FMR_SIZE + 1; /* +1 allows for unaligned MRs */
 unsigned int rds_ib_retry_count = RDS_IB_DEFAULT_RETRY_COUNT;
 
@@ -65,7 +65,7 @@ struct list_head rds_ib_devices;
 DEFINE_SPINLOCK(ib_nodev_conns_lock);
 LIST_HEAD(ib_nodev_conns);
 
-void rds_ib_nodev_connect(void)
+static void rds_ib_nodev_connect(void)
 {
 	struct rds_ib_connection *ic;
 
@@ -75,7 +75,7 @@ void rds_ib_nodev_connect(void)
 	spin_unlock(&ib_nodev_conns_lock);
 }
 
-void rds_ib_dev_shutdown(struct rds_ib_device *rds_ibdev)
+static void rds_ib_dev_shutdown(struct rds_ib_device *rds_ibdev)
 {
 	struct rds_ib_connection *ic;
 	unsigned long flags;
@@ -118,7 +118,7 @@ void rds_ib_dev_put(struct rds_ib_device
 		queue_work(rds_wq, &rds_ibdev->free_work);
 }
 
-void rds_ib_add_one(struct ib_device *device)
+static void rds_ib_add_one(struct ib_device *device)
 {
 	struct rds_ib_device *rds_ibdev;
 	struct ib_device_attr *dev_attr;
@@ -229,7 +229,7 @@ struct rds_ib_device *rds_ib_get_client_
  *
  * This can be called at any time and can be racing with any other RDS path.
  */
-void rds_ib_remove_one(struct ib_device *device)
+static void rds_ib_remove_one(struct ib_device *device)
 {
 	struct rds_ib_device *rds_ibdev;
 
--- a/net/rds/ib.h	2010-10-19 10:37:19.938432563 -0700
+++ b/net/rds/ib.h	2010-10-19 10:53:22.118325615 -0700
@@ -265,13 +265,10 @@ static inline void rds_ib_dma_sync_sg_fo
 
 /* ib.c */
 extern struct rds_transport rds_ib_transport;
-extern void rds_ib_add_one(struct ib_device *device);
-extern void rds_ib_remove_one(struct ib_device *device);
 struct rds_ib_device *rds_ib_get_client_data(struct ib_device *device);
 void rds_ib_dev_put(struct rds_ib_device *rds_ibdev);
 extern struct ib_client rds_ib_client;
 
-extern unsigned int fmr_pool_size;
 extern unsigned int fmr_message_size;
 extern unsigned int rds_ib_retry_count;
 
@@ -374,6 +371,5 @@ extern unsigned long rds_ib_sysctl_max_u
 extern unsigned long rds_ib_sysctl_max_unsig_bytes;
 extern unsigned long rds_ib_sysctl_max_recv_allocation;
 extern unsigned int rds_ib_sysctl_flow_control;
-extern ctl_table rds_ib_sysctl_table[];
 
 #endif
--- a/net/rds/ib_rdma.c	2010-10-19 10:38:36.109695644 -0700
+++ b/net/rds/ib_rdma.c	2010-10-19 10:38:43.474397946 -0700
@@ -38,7 +38,7 @@
 #include "ib.h"
 #include "xlist.h"
 
-struct workqueue_struct *rds_ib_fmr_wq;
+static struct workqueue_struct *rds_ib_fmr_wq;
 
 static DEFINE_PER_CPU(unsigned long, clean_list_grace);
 #define CLEAN_LIST_BUSY_BIT 0
--- a/net/rds/ib_sysctl.c	2010-10-19 10:39:22.998166930 -0700
+++ b/net/rds/ib_sysctl.c	2010-10-19 10:39:45.780252357 -0700
@@ -61,7 +61,7 @@ static unsigned long rds_ib_sysctl_max_u
  */
 unsigned int rds_ib_sysctl_flow_control = 0;
 
-ctl_table rds_ib_sysctl_table[] = {
+static ctl_table rds_ib_sysctl_table[] = {
 	{
 		.procname       = "max_send_wr",
 		.data		= &rds_ib_sysctl_max_send_wr,
--- a/net/rds/iw.c	2010-10-19 10:40:14.130811167 -0700
+++ b/net/rds/iw.c	2010-10-19 10:40:40.601201008 -0700
@@ -56,7 +56,7 @@ struct list_head rds_iw_devices;
 DEFINE_SPINLOCK(iw_nodev_conns_lock);
 LIST_HEAD(iw_nodev_conns);
 
-void rds_iw_add_one(struct ib_device *device)
+static void rds_iw_add_one(struct ib_device *device)
 {
 	struct rds_iw_device *rds_iwdev;
 	struct ib_device_attr *dev_attr;
@@ -124,7 +124,7 @@ free_attr:
 	kfree(dev_attr);
 }
 
-void rds_iw_remove_one(struct ib_device *device)
+static void rds_iw_remove_one(struct ib_device *device)
 {
 	struct rds_iw_device *rds_iwdev;
 	struct rds_iw_cm_id *i_cm_id, *next;
--- a/net/rds/iw.h	2010-10-19 10:53:48.052691754 -0700
+++ b/net/rds/iw.h	2010-10-19 10:54:09.078609969 -0700
@@ -268,8 +268,6 @@ static inline u32 rds_iw_local_dma_lkey(
 
 /* ib.c */
 extern struct rds_transport rds_iw_transport;
-extern void rds_iw_add_one(struct ib_device *device);
-extern void rds_iw_remove_one(struct ib_device *device);
 extern struct ib_client rds_iw_client;
 
 extern unsigned int fastreg_pool_size;
@@ -318,7 +316,6 @@ void *rds_iw_get_mr(struct scatterlist *
 void rds_iw_sync_mr(void *trans_private, int dir);
 void rds_iw_free_mr(void *trans_private, int invalidate);
 void rds_iw_flush_mrs(void);
-void rds_iw_remove_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_id);
 
 /* ib_recv.c */
 int rds_iw_recv_init(void);
@@ -378,7 +375,6 @@ extern unsigned long rds_iw_sysctl_max_u
 extern unsigned long rds_iw_sysctl_max_unsig_bytes;
 extern unsigned long rds_iw_sysctl_max_recv_allocation;
 extern unsigned int rds_iw_sysctl_flow_control;
-extern ctl_table rds_iw_sysctl_table[];
 
 /*
  * Helper functions for getting/setting the header and data SGEs in
--- a/net/rds/iw_rdma.c	2010-10-19 10:40:49.237980581 -0700
+++ b/net/rds/iw_rdma.c	2010-10-19 10:40:58.058777701 -0700
@@ -157,7 +157,8 @@ static int rds_iw_add_cm_id(struct rds_i
 	return 0;
 }
 
-void rds_iw_remove_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_id)
+static void rds_iw_remove_cm_id(struct rds_iw_device *rds_iwdev,
+				struct rdma_cm_id *cm_id)
 {
 	struct rds_iw_cm_id *i_cm_id;
 
--- a/net/rds/iw_sysctl.c	2010-10-19 10:41:15.516354119 -0700
+++ b/net/rds/iw_sysctl.c	2010-10-19 10:43:10.922788525 -0700
@@ -55,7 +55,7 @@ static unsigned long rds_iw_sysctl_max_u
 
 unsigned int rds_iw_sysctl_flow_control = 1;
 
-ctl_table rds_iw_sysctl_table[] = {
+static ctl_table rds_iw_sysctl_table[] = {
 	{
 		.procname       = "max_send_wr",
 		.data		= &rds_iw_sysctl_max_send_wr,
--- a/net/rds/message.c	2010-10-19 10:43:34.584930068 -0700
+++ b/net/rds/message.c	2010-10-19 10:59:47.121527590 -0700
@@ -106,8 +106,8 @@ void rds_message_populate_header(struct
 }
 EXPORT_SYMBOL_GPL(rds_message_populate_header);
 
-int rds_message_add_extension(struct rds_header *hdr,
-		unsigned int type, const void *data, unsigned int len)
+int rds_message_add_extension(struct rds_header *hdr, unsigned int type,
+			      const void *data, unsigned int len)
 {
 	unsigned int ext_len = sizeof(u8) + len;
 	unsigned char *dst;
@@ -177,26 +177,6 @@ none:
 	return RDS_EXTHDR_NONE;
 }
 
-int rds_message_add_version_extension(struct rds_header *hdr, unsigned int version)
-{
-	struct rds_ext_header_version ext_hdr;
-
-	ext_hdr.h_version = cpu_to_be32(version);
-	return rds_message_add_extension(hdr, RDS_EXTHDR_VERSION, &ext_hdr, sizeof(ext_hdr));
-}
-
-int rds_message_get_version_extension(struct rds_header *hdr, unsigned int *version)
-{
-	struct rds_ext_header_version ext_hdr;
-	unsigned int pos = 0, len = sizeof(ext_hdr);
-
-	/* We assume the version extension is the only one present */
-	if (rds_message_next_extension(hdr, &pos, &ext_hdr, &len) != RDS_EXTHDR_VERSION)
-		return 0;
-	*version = be32_to_cpu(ext_hdr.h_version);
-	return 1;
-}
-
 int rds_message_add_rdma_dest_extension(struct rds_header *hdr, u32 r_key, u32 offset)
 {
 	struct rds_ext_header_rdma_dest ext_hdr;
--- a/net/rds/rdma_transport.c	2010-10-19 10:44:45.687369510 -0700
+++ b/net/rds/rdma_transport.c	2010-10-19 10:45:03.729004485 -0700
@@ -207,7 +207,7 @@ static void rds_rdma_listen_stop(void)
 	}
 }
 
-int rds_rdma_init(void)
+static int rds_rdma_init(void)
 {
 	int ret;
 
@@ -234,7 +234,7 @@ out:
 }
 module_init(rds_rdma_init);
 
-void rds_rdma_exit(void)
+static void rds_rdma_exit(void)
 {
 	/* stop listening first to ensure no new connections are attempted */
 	rds_rdma_listen_stop();
--- a/net/rds/rdma_transport.h	2010-10-19 10:53:05.556814850 -0700
+++ b/net/rds/rdma_transport.h	2010-10-19 10:53:17.429897281 -0700
@@ -11,10 +11,6 @@ int rds_rdma_conn_connect(struct rds_con
 int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 			      struct rdma_cm_event *event);
 
-/* from rdma_transport.c */
-int rds_rdma_init(void);
-void rds_rdma_exit(void);
-
 /* from ib.c */
 extern struct rds_transport rds_ib_transport;
 int rds_ib_init(void);
--- a/net/rds/rds.h	2010-10-19 10:46:16.483601811 -0700
+++ b/net/rds/rds.h	2010-10-19 10:59:20.875122353 -0700
@@ -619,7 +619,6 @@ struct rds_connection *rds_conn_create_o
 			       struct rds_transport *trans, gfp_t gfp);
 void rds_conn_shutdown(struct rds_connection *conn);
 void rds_conn_destroy(struct rds_connection *conn);
-void rds_conn_reset(struct rds_connection *conn);
 void rds_conn_drop(struct rds_connection *conn);
 void rds_conn_connect_if_down(struct rds_connection *conn);
 void rds_for_each_conn_info(struct socket *sock, unsigned int len,
@@ -668,8 +667,6 @@ int rds_message_add_extension(struct rds
 			      unsigned int type, const void *data, unsigned int len);
 int rds_message_next_extension(struct rds_header *hdr,
 			       unsigned int *pos, void *buf, unsigned int *buflen);
-int rds_message_add_version_extension(struct rds_header *hdr, unsigned int version);
-int rds_message_get_version_extension(struct rds_header *hdr, unsigned int *version);
 int rds_message_add_rdma_dest_extension(struct rds_header *hdr, u32 r_key, u32 offset);
 int rds_message_inc_copy_to_user(struct rds_incoming *inc,
 				 struct iovec *first_iov, size_t size);
@@ -706,7 +703,6 @@ void rds_page_exit(void);
 /* recv.c */
 void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 		  __be32 saddr);
-void rds_inc_addref(struct rds_incoming *inc);
 void rds_inc_put(struct rds_incoming *inc);
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		       struct rds_incoming *inc, gfp_t gfp, enum km_type km);
@@ -728,7 +724,6 @@ void rds_send_drop_to(struct rds_sock *r
 typedef int (*is_acked_func)(struct rds_message *rm, uint64_t ack);
 void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 			 is_acked_func is_acked);
-void rds_send_remove_from_sock(struct list_head *messages, int status);
 int rds_send_pong(struct rds_connection *conn, __be16 dport);
 struct rds_message *rds_send_get_message(struct rds_connection *,
 					 struct rm_rdma_op *);
--- a/net/rds/recv.c	2010-10-19 10:45:14.810008886 -0700
+++ b/net/rds/recv.c	2010-10-19 10:45:35.707903271 -0700
@@ -48,12 +48,11 @@ void rds_inc_init(struct rds_incoming *i
 }
 EXPORT_SYMBOL_GPL(rds_inc_init);
 
-void rds_inc_addref(struct rds_incoming *inc)
+static void rds_inc_addref(struct rds_incoming *inc)
 {
 	rdsdebug("addref inc %p ref %d\n", inc, atomic_read(&inc->i_refcount));
 	atomic_inc(&inc->i_refcount);
 }
-EXPORT_SYMBOL_GPL(rds_inc_addref);
 
 void rds_inc_put(struct rds_incoming *inc)
 {
--- a/net/rds/send.c	2010-10-19 10:45:43.272589570 -0700
+++ b/net/rds/send.c	2010-10-19 10:46:36.589425686 -0700
@@ -52,6 +52,8 @@ static int send_batch_count = 64;
 module_param(send_batch_count, int, 0444);
 MODULE_PARM_DESC(send_batch_count, " batch factor when working the send queue");
 
+static void rds_send_remove_from_sock(struct list_head *messages, int status);
+
 /*
  * Reset the send state.  Callers must ensure that this doesn't race with
  * rds_send_xmit().
@@ -555,7 +557,7 @@ EXPORT_SYMBOL_GPL(rds_send_get_message);
  * removing the messages from the 'messages' list regardless of if it found
  * the messages on the socket list or not.
  */
-void rds_send_remove_from_sock(struct list_head *messages, int status)
+static void rds_send_remove_from_sock(struct list_head *messages, int status)
 {
 	unsigned long flags;
 	struct rds_sock *rs = NULL;
--- a/net/rds/tcp.c	2010-10-19 10:46:52.450865841 -0700
+++ b/net/rds/tcp.c	2010-10-19 10:47:54.492499537 -0700
@@ -41,7 +41,7 @@
 /* only for info exporting */
 static DEFINE_SPINLOCK(rds_tcp_tc_list_lock);
 static LIST_HEAD(rds_tcp_tc_list);
-unsigned int rds_tcp_tc_count;
+static unsigned int rds_tcp_tc_count;
 
 /* Track rds_tcp_connection structs so they can be cleaned up */
 static DEFINE_SPINLOCK(rds_tcp_conn_lock);
@@ -243,7 +243,7 @@ static void rds_tcp_destroy_conns(void)
 	}
 }
 
-void rds_tcp_exit(void)
+static void rds_tcp_exit(void)
 {
 	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
 	rds_tcp_listen_stop();
@@ -274,7 +274,7 @@ struct rds_transport rds_tcp_transport =
 	.t_prefer_loopback	= 1,
 };
 
-int rds_tcp_init(void)
+static int rds_tcp_init(void)
 {
 	int ret;
 
--- a/net/rds/tcp.h	2010-10-19 10:54:15.559202132 -0700
+++ b/net/rds/tcp.h	2010-10-19 10:55:08.212010108 -0700
@@ -43,8 +43,6 @@ struct rds_tcp_statistics {
 };
 
 /* tcp.c */
-int rds_tcp_init(void);
-void rds_tcp_exit(void);
 void rds_tcp_tune(struct socket *sock);
 void rds_tcp_nonagle(struct socket *sock);
 void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn);
--- a/net/rds/tcp_recv.c	2010-10-19 10:48:47.077278176 -0700
+++ b/net/rds/tcp_recv.c	2010-10-19 10:48:59.814436186 -0700
@@ -272,7 +272,8 @@ out:
 }
 
 /* the caller has to hold the sock lock */
-int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp, enum km_type km)
+static int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp,
+			     enum km_type km)
 {
 	struct rds_tcp_connection *tc = conn->c_transport_data;
 	struct socket *sock = tc->t_sock;
--- a/net/rds/tcp_send.c	2010-10-19 10:49:25.756795362 -0700
+++ b/net/rds/tcp_send.c	2010-10-19 10:49:40.974179535 -0700
@@ -63,7 +63,7 @@ void rds_tcp_xmit_complete(struct rds_co
 }
 
 /* the core send_sem serializes this with other xmit and shutdown */
-int rds_tcp_sendmsg(struct socket *sock, void *data, unsigned int len)
+static int rds_tcp_sendmsg(struct socket *sock, void *data, unsigned int len)
 {
 	struct kvec vec = {
                 .iov_base = data,
--- a/net/rds/page.c	2010-10-19 11:00:18.352389347 -0700
+++ b/net/rds/page.c	2010-10-19 11:01:04.412612535 -0700
@@ -40,7 +40,8 @@ struct rds_page_remainder {
 	unsigned long	r_offset;
 };
 
-DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_page_remainder, rds_page_remainders);
+static DEFINE_PER_CPU_SHARED_ALIGNED(struct rds_page_remainder,
+				     rds_page_remainders);
 
 /*
  * returns 0 on success or -errno on failure.
