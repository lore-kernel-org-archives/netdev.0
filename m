From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 06/19] RDMA/netlink: Rename netlink callback struct
Date: Thu, 22 Jun 2017 16:24:21 +0300
Message-ID: <20170622132434.1327-7-leon@kernel.org>
References: <20170622132434.1327-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60904 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753171AbdFVNZr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:25:47 -0400
In-Reply-To: <20170622132434.1327-1-leon@kernel.org>
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
index a4013b0908e2..2af30a19b926 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -4477,7 +4477,7 @@ static int cma_get_id_stats(struct sk_buff *skb, struct netlink_callback *cb)
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
index 1022ce6628ae..14b64e4d1e06 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -43,7 +43,7 @@
 static DEFINE_MUTEX(rdma_nl_mutex);
 static struct sock *nls;
 static struct {
-	const struct ibnl_client_cbs   *cb_table;
+	const struct rdma_nl_cbs   *cb_table;
 } rdma_nl_types[RDMA_NL_NUM_CLIENTS];
 
 int rdma_nl_chk_listeners(unsigned int group)
@@ -83,7 +83,7 @@ static bool is_nl_valid(unsigned int type, unsigned int op)
 }
 
 void rdma_nl_register(unsigned int index,
-		      const struct ibnl_client_cbs cb_table[])
+		      const struct rdma_nl_cbs cb_table[])
 {
 	mutex_lock(&rdma_nl_mutex);
 	if (!is_nl_msg_valid(index, 0)) {
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index b39e030b3a64..8feeb899e2b2 100644
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
@@ -24,7 +24,7 @@ void rdma_nl_exit(void);
  * @cb_table: A table for op->callback
  */
 void rdma_nl_register(unsigned int index,
-		      const struct ibnl_client_cbs cb_table[]);
+		      const struct rdma_nl_cbs cb_table[]);
 
 /**
  * Remove a client from IB netlink.
-- 
2.13.1
