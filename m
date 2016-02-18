From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/5] openvswitch: Revert: "Enable memory mapped Netlink i/o"
Date: Thu, 18 Feb 2016 15:03:25 +0100
Message-ID: <1455804208-30512-3-git-send-email-fw@strlen.de>
References: <1455804208-30512-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50167 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1425963AbcBRODw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 09:03:52 -0500
In-Reply-To: <1455804208-30512-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

revert commit 795449d8b846 ("openvswitch: Enable memory mapped Netlink i/o").
Following the mmaped netlink removal this code can be removed.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/openvswitch/datapath.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d6f7fe9..35a2659 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -422,10 +422,6 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb = NULL; /* to be queued to userspace */
 	struct nlattr *nla;
-	struct genl_info info = {
-		.dst_sk = ovs_dp_get_net(dp)->genl_sock,
-		.snd_portid = upcall_info->portid,
-	};
 	size_t len;
 	unsigned int hlen;
 	int err, dp_ifindex;
@@ -466,7 +462,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		hlen = skb->len;
 
 	len = upcall_msg_size(upcall_info, hlen);
-	user_skb = genlmsg_new_unicast(len, &info, GFP_ATOMIC);
+	user_skb = genlmsg_new(len, GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -876,7 +872,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
 		return NULL;
 
 	len = ovs_flow_cmd_msg_size(acts, sfid, ufid_flags);
-	skb = genlmsg_new_unicast(len, info, GFP_KERNEL);
+	skb = genlmsg_new(len, GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
@@ -1483,7 +1479,7 @@ error:
 
 static struct sk_buff *ovs_dp_cmd_alloc_info(struct genl_info *info)
 {
-	return genlmsg_new_unicast(ovs_dp_cmd_msg_size(), info, GFP_KERNEL);
+	return genlmsg_new(ovs_dp_cmd_msg_size(), GFP_KERNEL);
 }
 
 /* Called with rcu_read_lock or ovs_mutex. */
-- 
2.4.10
