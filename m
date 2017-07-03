From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V2 23/27] RDMA/netlink: Advertise IB subnet prefix
Date: Mon,  3 Jul 2017 09:28:26 +0300
Message-ID: <20170703062830.30361-24-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170703062830.30361-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add IB subnet prefix to the port properties exported
by RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/nldev.c  | 5 +++++
 include/uapi/rdma/rdma_netlink.h | 5 +++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index fde0138fff5f..c4884841e2fe 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -44,6 +44,7 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 					    .len = IB_FW_VERSION_NAME_MAX - 1},
 	[RDMA_NLDEV_ATTR_NODE_GUID]	= { .type = NLA_U64 },
 	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = { .type = NLA_U64 },
+	[RDMA_NLDEV_ATTR_SUBNET_PREFIX]	= { .type = NLA_U64 },
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
@@ -97,6 +98,10 @@ static int fill_port_info(struct sk_buff *msg,
 	if (nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_CAP_FLAGS,
 			      (u64)attr.port_cap_flags, 0))
 		return -EMSGSIZE;
+	if (rdma_protocol_ib(device, port) &&
+	    nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_SUBNET_PREFIX,
+			      attr.subnet_prefix, 0))
+		return -EMSGSIZE;
 
 	return 0;
 }
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index b34f7745daf0..24712d810dca 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -279,6 +279,11 @@ enum rdma_nldev_attr {
 	 */
 	RDMA_NLDEV_ATTR_SYS_IMAGE_GUID,		/* u64 */
 
+	/*
+	 * Subnet prefix (in host byte order)
+	 */
+	RDMA_NLDEV_ATTR_SUBNET_PREFIX,		/* u64 */
+
 	RDMA_NLDEV_ATTR_MAX
 };
 #endif /* _UAPI_RDMA_NETLINK_H */
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
