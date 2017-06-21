From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next 04/19] RDMA/netlink: Rename and remove redundant parameter from ibnl_multicast
Date: Wed, 21 Jun 2017 09:05:13 +0300
Message-ID: <20170621060528.3752-5-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621060528.3752-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

The pointer to netlink header was not used in the ibnl_multicast
function, so let's remove it and simplify the function
signature.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/addr.c     | 2 +-
 drivers/infiniband/core/iwpm_msg.c | 2 +-
 drivers/infiniband/core/netlink.c  | 5 ++---
 drivers/infiniband/core/sa_query.c | 2 +-
 include/rdma/rdma_netlink.h        | 4 +---
 5 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 134d8394fca5..ebd0242bab3d 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -185,7 +185,7 @@ static int ib_nl_ip_send_msg(struct rdma_dev_addr *dev_addr,
 
 	/* Repair the nlmsg header length */
 	nlmsg_end(skb, nlh);
-	ibnl_multicast(skb, nlh, RDMA_NL_GROUP_LS, GFP_KERNEL);
+	rdma_nl_multicast(skb, RDMA_NL_GROUP_LS, GFP_KERNEL);
 
 	/* Make the request retry, so when we get the response from userspace
 	 * we will have something.
diff --git a/drivers/infiniband/core/iwpm_msg.c b/drivers/infiniband/core/iwpm_msg.c
index 8f84557d04e3..561f312ea35a 100644
--- a/drivers/infiniband/core/iwpm_msg.c
+++ b/drivers/infiniband/core/iwpm_msg.c
@@ -103,7 +103,7 @@ int iwpm_register_pid(struct iwpm_dev_data *pm_msg, u8 nl_client)
 	pr_debug("%s: Multicasting a nlmsg (dev = %s ifname = %s iwpm = %s)\n",
 		__func__, pm_msg->dev_name, pm_msg->if_name, iwpm_ulib_name);
 
-	ret = ibnl_multicast(skb, nlh, RDMA_NL_GROUP_IWPM, GFP_KERNEL);
+	ret = rdma_nl_multicast(skb, RDMA_NL_GROUP_IWPM, GFP_KERNEL);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNAVAILABLE;
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index cd29311078b5..89a6219b6ec8 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -247,12 +247,11 @@ int rdma_nl_unicast(struct sk_buff *skb, u32 pid)
 }
 EXPORT_SYMBOL(rdma_nl_unicast);
 
-int ibnl_multicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			unsigned int group, gfp_t flags)
+int rdma_nl_multicast(struct sk_buff *skb, unsigned int group, gfp_t flags)
 {
 	return nlmsg_multicast(nls, skb, 0, group, flags);
 }
-EXPORT_SYMBOL(ibnl_multicast);
+EXPORT_SYMBOL(rdma_nl_multicast);
 
 int __init rdma_nl_init(void)
 {
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 6e39a763b220..d890600f1e2d 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -862,7 +862,7 @@ static int ib_nl_send_msg(struct ib_sa_query *query, gfp_t gfp_mask)
 	/* Repair the nlmsg header length */
 	nlmsg_end(skb, nlh);
 
-	ret = ibnl_multicast(skb, nlh, RDMA_NL_GROUP_LS, gfp_mask);
+	ret = rdma_nl_multicast(skb, RDMA_NL_GROUP_LS, gfp_mask);
 	if (!ret)
 		ret = len;
 	else
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 9779cd5520d7..145283896417 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -67,13 +67,11 @@ int rdma_nl_unicast(struct sk_buff *skb, u32 pid);
 /**
  * Send the supplied skb to a netlink group.
  * @skb: The netlink skb
- * @nlh: Header of the netlink message to send
  * @group: Netlink group ID
  * @flags: allocation flags
  * Returns 0 on success or a negative error code.
  */
-int ibnl_multicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			unsigned int group, gfp_t flags);
+int rdma_nl_multicast(struct sk_buff *skb, unsigned int group, gfp_t flags);
 
 /**
  * Check if there are any listeners to the netlink group
-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
