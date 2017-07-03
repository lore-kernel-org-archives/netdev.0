From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 06/27] RDMA/netlink: Rename netlink callback struct
Date: Mon,  3 Jul 2017 09:28:09 +0300
Message-ID: <20170703062830.30361-7-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59350 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752633AbdGCG3B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:01 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

The RDMA netlink client infrastructure was removed and made
obsolete the old name (ibnl_client_cbs). This patch renames
to the more appropriate name (rdma_nl_cbs).

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Reviewed-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/core/cma.c     | 2 +-
 drivers/infiniband/core/device.c  | 2 +-
 drivers/infiniband/core/iwcm.c    | 2 +-
 drivers/infiniband/core/netlink.c | 4 ++--
 include/rdma/rdma_netlink.h       | 4 ++--
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e0189a130014..8c2665637b4b 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -4476,7 +4476,7 @@ static int cma_get_id_stats(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-static const struct ibnl_client_cbs cma_cb_table[] = {
+static const struct rdma_nl_cbs cma_cb_table[] = {
 	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats},
 };
 
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 2001dabd1444..5326dcc6ede7 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -1008,7 +1008,7 @@ struct net_device *ib_get_net_dev_by_params(struct ib_device *dev,
 }
 EXPORT_SYMBOL(ib_get_net_dev_by_params);
 
-static const struct ibnl_client_cbs ibnl_ls_cb_table[] = {
+static const struct rdma_nl_cbs ibnl_ls_cb_table[] = {
 	[RDMA_NL_LS_OP_RESOLVE] = {
 		.dump = ib_nl_handle_resolve_resp,
 		.flags = RDMA_NL_ADMIN_PERM,
diff --git a/drivers/infiniband/core/iwcm.c b/drivers/infiniband/core/iwcm.c
index 8599271d8be6..452a3115e3e6 100644
--- a/drivers/infiniband/core/iwcm.c
+++ b/drivers/infiniband/core/iwcm.c
@@ -80,7 +80,7 @@ const char *__attribute_const__ iwcm_reject_msg(int reason)
 }
 EXPORT_SYMBOL(iwcm_reject_msg);
 
-static struct ibnl_client_cbs iwcm_nl_cb_table[] = {
+static struct rdma_nl_cbs iwcm_nl_cb_table[] = {
 	[RDMA_NL_IWPM_REG_PID] = {.dump = iwpm_register_pid_cb},
 	[RDMA_NL_IWPM_ADD_MAPPING] = {.dump = iwpm_add_mapping_cb},
 	[RDMA_NL_IWPM_QUERY_MAPPING] = {.dump = iwpm_add_and_query_mapping_cb},
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index d1d187f27297..4d8c8b5583c6 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -44,7 +44,7 @@
 static DEFINE_MUTEX(rdma_nl_mutex);
 static struct sock *nls;
 static struct {
-	const struct ibnl_client_cbs   *cb_table;
+	const struct rdma_nl_cbs   *cb_table;
 } rdma_nl_types[RDMA_NL_NUM_CLIENTS];
 
 int rdma_nl_chk_listeners(unsigned int group)
@@ -84,7 +84,7 @@ static bool is_nl_valid(unsigned int type, unsigned int op)
 }
 
 void rdma_nl_register(unsigned int index,
-		      const struct ibnl_client_cbs cb_table[])
+		      const struct rdma_nl_cbs cb_table[])
 {
 	mutex_lock(&rdma_nl_mutex);
 	if (!is_nl_msg_valid(index, 0)) {
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index afc364c3220c..17565a2765c4 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -5,7 +5,7 @@
 #include <linux/netlink.h>
 #include <uapi/rdma/rdma_netlink.h>
 
-struct ibnl_client_cbs {
+struct rdma_nl_cbs {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
 	u8 flags;
 };
@@ -21,7 +21,7 @@ enum rdma_nl_flags {
  * @cb_table: A table for op->callback
  */
 void rdma_nl_register(unsigned int index,
-		      const struct ibnl_client_cbs cb_table[]);
+		      const struct rdma_nl_cbs cb_table[]);
 
 /**
  * Remove a client from IB netlink.
-- 
2.13.2
