From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/21] netfilter: nfnetlink: get rid of u_intX_t types
Date: Sun, 12 Feb 2017 20:42:47 +0100
Message-ID: <1486928573-24773-16-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60512 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751420AbdBLTnW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 14:43:22 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 008F7BA6EB
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E59DDDA85F
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:20 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C1CB1DA84A
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 20:43:18 +0100 (CET)
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use uX types instead.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index a09fa9fd8f3d..586212ebba9e 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -100,9 +100,9 @@ int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_subsys_unregister);
 
-static inline const struct nfnetlink_subsystem *nfnetlink_get_subsys(u_int16_t type)
+static inline const struct nfnetlink_subsystem *nfnetlink_get_subsys(u16 type)
 {
-	u_int8_t subsys_id = NFNL_SUBSYS_ID(type);
+	u8 subsys_id = NFNL_SUBSYS_ID(type);
 
 	if (subsys_id >= NFNL_SUBSYS_COUNT)
 		return NULL;
@@ -111,9 +111,9 @@ static inline const struct nfnetlink_subsystem *nfnetlink_get_subsys(u_int16_t t
 }
 
 static inline const struct nfnl_callback *
-nfnetlink_find_client(u_int16_t type, const struct nfnetlink_subsystem *ss)
+nfnetlink_find_client(u16 type, const struct nfnetlink_subsystem *ss)
 {
-	u_int8_t cb_id = NFNL_MSG_TYPE(type);
+	u8 cb_id = NFNL_MSG_TYPE(type);
 
 	if (cb_id >= ss->cb_count)
 		return NULL;
@@ -185,7 +185,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	{
 		int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
-		u_int8_t cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
+		u8 cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
 		struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
 		struct nlattr *attr = (void *)nlh + min_len;
 		int attrlen = nlh->nlmsg_len - min_len;
@@ -273,7 +273,7 @@ enum {
 };
 
 static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
-				u_int16_t subsys_id)
+				u16 subsys_id)
 {
 	struct sk_buff *oskb = skb;
 	struct net *net = sock_net(skb->sk);
@@ -365,7 +365,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 		{
 			int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
-			u_int8_t cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
+			u8 cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
 			struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
 			struct nlattr *attr = (void *)nlh + min_len;
 			int attrlen = nlh->nlmsg_len - min_len;
@@ -439,7 +439,7 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 static void nfnetlink_rcv(struct sk_buff *skb)
 {
 	struct nlmsghdr *nlh = nlmsg_hdr(skb);
-	u_int16_t res_id;
+	u16 res_id;
 	int msglen;
 
 	if (nlh->nlmsg_len < NLMSG_HDRLEN ||
-- 
2.1.4
