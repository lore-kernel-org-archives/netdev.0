From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 25/27] RDMA/netlink: Export LID mask counter (LMC)
Date: Mon,  3 Jul 2017 09:28:28 +0300
Message-ID: <20170703062830.30361-26-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59724 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752765AbdGCGaF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:30:05 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/nldev.c  | 3 +++
 include/uapi/rdma/rdma_netlink.h | 5 +++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index ce733bf33ed9..f968a40ef5d3 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -47,6 +47,7 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_SUBNET_PREFIX]	= { .type = NLA_U64 },
 	[RDMA_NLDEV_ATTR_LID]		= { .type = NLA_U32 },
 	[RDMA_NLDEV_ATTR_SM_LID]	= { .type = NLA_U32 },
+	[RDMA_NLDEV_ATTR_LMC]		= { .type = NLA_U8 },
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
@@ -109,6 +110,8 @@ static int fill_port_info(struct sk_buff *msg,
 			return -EMSGSIZE;
 		if (nla_put_u32(msg, RDMA_NLDEV_ATTR_SM_LID, attr.sm_lid))
 			return -EMSGSIZE;
+		if (nla_put_u8(msg, RDMA_NLDEV_ATTR_LMC, attr.lmc))
+			return -EMSGSIZE;
 	}
 	return 0;
 }
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index 82e0d64346e1..d4b862e8ed15 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -292,6 +292,11 @@ enum rdma_nldev_attr {
 	RDMA_NLDEV_ATTR_LID,			/* u32 */
 	RDMA_NLDEV_ATTR_SM_LID,			/* u32 */
 
+	/*
+	 * LID mask count (LMC)
+	 */
+	RDMA_NLDEV_ATTR_LMC,			/* u8 */
+
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2
