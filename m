From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 26/27] RDMA/netlink: Provide port state and physical link state
Date: Mon,  3 Jul 2017 09:28:29 +0300
Message-ID: <20170703062830.30361-27-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59480 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752702AbdGCG31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:27 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Add port state and physical link state to the users of RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c  | 6 ++++++
 include/uapi/rdma/rdma_netlink.h | 3 +++
 2 files changed, 9 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index f968a40ef5d3..30fe1e9ff5ce 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -48,6 +48,8 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_LID]		= { .type = NLA_U32 },
 	[RDMA_NLDEV_ATTR_SM_LID]	= { .type = NLA_U32 },
 	[RDMA_NLDEV_ATTR_LMC]		= { .type = NLA_U8 },
+	[RDMA_NLDEV_ATTR_PORT_STATE]	= { .type = NLA_U8 },
+	[RDMA_NLDEV_ATTR_PORT_PHYS_STATE] = { .type = NLA_U8 },
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
@@ -113,6 +115,10 @@ static int fill_port_info(struct sk_buff *msg,
 		if (nla_put_u8(msg, RDMA_NLDEV_ATTR_LMC, attr.lmc))
 			return -EMSGSIZE;
 	}
+	if (nla_put_u8(msg, RDMA_NLDEV_ATTR_PORT_STATE, attr.state))
+		return -EMSGSIZE;
+	if (nla_put_u8(msg, RDMA_NLDEV_ATTR_PORT_PHYS_STATE, attr.phys_state))
+		return -EMSGSIZE;
 	return 0;
 }
 
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index d4b862e8ed15..936e55d39a12 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -297,6 +297,9 @@ enum rdma_nldev_attr {
 	 */
 	RDMA_NLDEV_ATTR_LMC,			/* u8 */
 
+	RDMA_NLDEV_ATTR_PORT_STATE,		/* u8 */
+	RDMA_NLDEV_ATTR_PORT_PHYS_STATE,	/* u8 */
+
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2
