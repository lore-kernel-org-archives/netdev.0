From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 05/19] RDMA/netlink: Simplify and rename ibnl_chk_listeners
Date: Wed, 21 Jun 2017 09:05:14 +0300
Message-ID: <20170621060528.3752-6-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57700 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751071AbdFUGFs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:05:48 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Make ibnl_chk_listeners function to be one line by removing
unneeded comparison.

Rename that function to be complaint to other functions in RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/addr.c     | 2 +-
 drivers/infiniband/core/netlink.c  | 8 +++-----
 drivers/infiniband/core/sa_query.c | 2 +-
 include/rdma/rdma_netlink.h        | 2 +-
 4 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index ebd0242bab3d..2cc23a26ce4f 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -324,7 +324,7 @@ static void queue_req(struct addr_req *req)
 static int ib_nl_fetch_ha(struct dst_entry *dst, struct rdma_dev_addr *dev_addr,
 			  const void *daddr, u32 seq, u16 family)
 {
-	if (ibnl_chk_listeners(RDMA_NL_GROUP_LS))
+	if (rdma_nl_chk_listeners(RDMA_NL_GROUP_LS))
 		return -EADDRNOTAVAIL;
 
 	/* We fill in what we can, the response will fill the rest */
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 89a6219b6ec8..1022ce6628ae 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -46,13 +46,11 @@ static struct {
 	const struct ibnl_client_cbs   *cb_table;
 } rdma_nl_types[RDMA_NL_NUM_CLIENTS];
 
-int ibnl_chk_listeners(unsigned int group)
+int rdma_nl_chk_listeners(unsigned int group)
 {
-	if (netlink_has_listeners(nls, group) == 0)
-		return -1;
-	return 0;
+	return (netlink_has_listeners(nls, group)) ? 0 : -1;
 }
-EXPORT_SYMBOL(ibnl_chk_listeners);
+EXPORT_SYMBOL(rdma_nl_chk_listeners);
 
 static bool is_nl_msg_valid(unsigned int type, unsigned int op)
 {
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index d890600f1e2d..c06b7deea4d2 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -1419,7 +1419,7 @@ static int send_mad(struct ib_sa_query *query, int timeout_ms, gfp_t gfp_mask)
 
 	if ((query->flags & IB_SA_ENABLE_LOCAL_SERVICE) &&
 	    (!(query->flags & IB_SA_QUERY_OPA))) {
-		if (!ibnl_chk_listeners(RDMA_NL_GROUP_LS)) {
+		if (!rdma_nl_chk_listeners(RDMA_NL_GROUP_LS)) {
 			if (!ib_nl_make_request(query, gfp_mask))
 				return id;
 		}
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 145283896417..b39e030b3a64 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -78,6 +78,6 @@ int rdma_nl_multicast(struct sk_buff *skb, unsigned int group, gfp_t flags);
  * @group: the netlink group ID
  * Returns 0 on success or a negative for no listeners.
  */
-int ibnl_chk_listeners(unsigned int group);
+int rdma_nl_chk_listeners(unsigned int group);
 
 #endif /* _RDMA_NETLINK_H */
-- 
2.13.1
