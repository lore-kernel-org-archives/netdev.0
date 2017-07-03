From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V2 27/27] RDMA/netlink: Export node_type
Date: Mon,  3 Jul 2017 09:28:30 +0300
Message-ID: <20170703062830.30361-28-leon@kernel.org>
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

Add ability to get node_type for RDAM netlink users.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/nldev.c  | 3 +++
 include/uapi/rdma/rdma_netlink.h | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/drivers/infiniband/core/nldev.c b/drivers/infiniband/core/nldev.c
index 30fe1e9ff5ce..7f04ef89398c 100644
--- a/drivers/infiniband/core/nldev.c
+++ b/drivers/infiniband/core/nldev.c
@@ -50,6 +50,7 @@ static const struct nla_policy nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_LMC]		= { .type = NLA_U8 },
 	[RDMA_NLDEV_ATTR_PORT_STATE]	= { .type = NLA_U8 },
 	[RDMA_NLDEV_ATTR_PORT_PHYS_STATE] = { .type = NLA_U8 },
+	[RDMA_NLDEV_ATTR_DEV_NODE_TYPE] = { .type = NLA_U8 },
 };
 
 static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
@@ -79,6 +80,8 @@ static int fill_dev_info(struct sk_buff *msg, struct ib_device *device)
 	if (nla_put_u64_64bit(msg, RDMA_NLDEV_ATTR_SYS_IMAGE_GUID,
 			      be64_to_cpu(device->attrs.sys_image_guid), 0))
 		return -EMSGSIZE;
+	if (nla_put_u8(msg, RDMA_NLDEV_ATTR_DEV_NODE_TYPE, device->node_type))
+		return -EMSGSIZE;
 	return 0;
 }
 
diff --git a/include/uapi/rdma/rdma_netlink.h b/include/uapi/rdma/rdma_netlink.h
index 936e55d39a12..2e895b1cef3b 100644
--- a/include/uapi/rdma/rdma_netlink.h
+++ b/include/uapi/rdma/rdma_netlink.h
@@ -300,6 +300,8 @@ enum rdma_nldev_attr {
 	RDMA_NLDEV_ATTR_PORT_STATE,		/* u8 */
 	RDMA_NLDEV_ATTR_PORT_PHYS_STATE,	/* u8 */
 
+	RDMA_NLDEV_ATTR_DEV_NODE_TYPE,		/* u8 */
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
