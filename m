From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v4 2/2] infiniband: pass rdma_cm module to netlink_dump_start
Date: Fri, 5 Oct 2012 14:15:49 +0800
Message-ID: <1349417749-24869-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1349417749-24869-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: eric.dumazet@gmail.com, steffen.klassert@secunet.com,
	pablo@netfilter.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, stephen.hemminger@vyatta.com,
	jengelh@inai.de, Gao feng <gaofeng@cn.fujitsu.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:23140 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab2JEG5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2012 02:57:25 -0400
In-Reply-To: <1349417749-24869-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

set netlink_dump_control.module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Roland Dreier <roland@kernel.org>
Cc: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/cma.c     |    3 ++-
 drivers/infiniband/core/netlink.c |    1 +
 include/rdma/rdma_netlink.h       |    1 +
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 26b3760..4fff27a 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -3498,7 +3498,8 @@ out:
 }
 
 static const struct ibnl_client_cbs cma_cb_table[] = {
-	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats },
+	[RDMA_NL_RDMA_CM_ID_STATS] = { .dump = cma_get_id_stats,
+				       .module = THIS_MODULE },
 };
 
 static int __init cma_init(void)
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index fe10a94..da06abd 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -154,6 +154,7 @@ static int ibnl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			{
 				struct netlink_dump_control c = {
 					.dump = client->cb_table[op].dump,
+					.module = client->cb_table[op].module,
 				};
 				return netlink_dump_start(nls, skb, nlh, &c);
 			}
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 3c5363a..bd3d8b2 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -39,6 +39,7 @@ struct rdma_cm_id_stats {
 
 struct ibnl_client_cbs {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *nlcb);
+	struct module *module;
 };
 
 int ibnl_init(void);
-- 
1.7.7.6
