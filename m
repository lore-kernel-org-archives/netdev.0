From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next V1 03/19] RDMA/netlink: Rename and remove redundant parameter from ibnl_unicast
Date: Thu, 22 Jun 2017 16:24:18 +0300
Message-ID: <20170622132434.1327-4-leon@kernel.org>
References: <20170622132434.1327-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170622132434.1327-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Netlink message header is not needed for unicast reply, hence remove it.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/core/iwpm_msg.c  | 6 +++---
 drivers/infiniband/core/iwpm_util.c | 4 ++--
 drivers/infiniband/core/netlink.c   | 5 ++---
 include/rdma/rdma_netlink.h         | 4 +---
 4 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/core/iwpm_msg.c b/drivers/infiniband/core/iwpm_msg.c
index 1fab707b1f68..8f84557d04e3 100644
--- a/drivers/infiniband/core/iwpm_msg.c
+++ b/drivers/infiniband/core/iwpm_msg.c
@@ -172,7 +172,7 @@ int iwpm_add_mapping(struct iwpm_sa_data *pm_msg, u8 nl_client)
 		goto add_mapping_error;
 	nlmsg_request->req_buffer = pm_msg;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = rdma_nl_unicast(skb, iwpm_user_pid);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNDEFINED;
@@ -248,7 +248,7 @@ int iwpm_add_and_query_mapping(struct iwpm_sa_data *pm_msg, u8 nl_client)
 		goto query_mapping_error;
 	nlmsg_request->req_buffer = pm_msg;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = rdma_nl_unicast(skb, iwpm_user_pid);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		err_str = "Unable to send a nlmsg";
@@ -308,7 +308,7 @@ int iwpm_remove_mapping(struct sockaddr_storage *local_addr, u8 nl_client)
 	if (ret)
 		goto remove_mapping_error;
 
-	ret = ibnl_unicast(skb, nlh, iwpm_user_pid);
+	ret = rdma_nl_unicast(skb, iwpm_user_pid);
 	if (ret) {
 		skb = NULL; /* skb is freed in the netlink send-op handling */
 		iwpm_user_pid = IWPM_PID_UNDEFINED;
diff --git a/drivers/infiniband/core/iwpm_util.c b/drivers/infiniband/core/iwpm_util.c
index c46442ac71a2..c81c55942626 100644
--- a/drivers/infiniband/core/iwpm_util.c
+++ b/drivers/infiniband/core/iwpm_util.c
@@ -597,7 +597,7 @@ static int send_mapinfo_num(u32 mapping_num, u8 nl_client, int iwpm_pid)
 				&mapping_num, IWPM_NLA_MAPINFO_SEND_NUM);
 	if (ret)
 		goto mapinfo_num_error;
-	ret = ibnl_unicast(skb, nlh, iwpm_pid);
+	ret = rdma_nl_unicast(skb, iwpm_pid);
 	if (ret) {
 		skb = NULL;
 		err_str = "Unable to send a nlmsg";
@@ -626,7 +626,7 @@ static int send_nlmsg_done(struct sk_buff *skb, u8 nl_client, int iwpm_pid)
 		return -ENOMEM;
 	}
 	nlh->nlmsg_type = NLMSG_DONE;
-	ret = ibnl_unicast(skb, (struct nlmsghdr *)skb->data, iwpm_pid);
+	ret = rdma_nl_unicast(skb, iwpm_pid);
 	if (ret)
 		pr_warn("%s Unable to send a nlmsg\n", __func__);
 	return ret;
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 96057e722123..cd29311078b5 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -241,12 +241,11 @@ static void rdma_nl_rcv(struct sk_buff *skb)
 	mutex_unlock(&rdma_nl_mutex);
 }
 
-int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			__u32 pid)
+int rdma_nl_unicast(struct sk_buff *skb, u32 pid)
 {
 	return nlmsg_unicast(nls, skb, pid);
 }
-EXPORT_SYMBOL(ibnl_unicast);
+EXPORT_SYMBOL(rdma_nl_unicast);
 
 int ibnl_multicast(struct sk_buff *skb, struct nlmsghdr *nlh,
 			unsigned int group, gfp_t flags)
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
index 6932b7acd3a6..9779cd5520d7 100644
--- a/include/rdma/rdma_netlink.h
+++ b/include/rdma/rdma_netlink.h
@@ -59,12 +59,10 @@ int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
 /**
  * Send the supplied skb to a specific userspace PID.
  * @skb: The netlink skb
- * @nlh: Header of the netlink message to send
  * @pid: Userspace netlink process ID
  * Returns 0 on success or a negative error code.
  */
-int ibnl_unicast(struct sk_buff *skb, struct nlmsghdr *nlh,
-			__u32 pid);
+int rdma_nl_unicast(struct sk_buff *skb, u32 pid);
 
 /**
  * Send the supplied skb to a netlink group.
-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
