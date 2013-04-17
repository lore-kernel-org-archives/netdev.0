From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 02/14] netlink: rename ssk to sk in struct netlink_skb_params
Date: Wed, 17 Apr 2013 18:46:57 +0200
Message-ID: <1366217229-22705-3-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60951 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756871Ab3DQQrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:47:24 -0400
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory mapped netlink needs to store the receiving userspace socket
when sending from the kernel to userspace. Rename 'ssk' to 'sk' to
avoid confusion.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netlink.h       | 2 +-
 net/ipv4/inet_diag.c          | 6 +++---
 net/ipv4/udp_diag.c           | 4 ++--
 net/netfilter/nfnetlink_log.c | 2 +-
 net/netlink/af_netlink.c      | 2 +-
 net/sched/cls_flow.c          | 2 +-
 6 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e0f746b..d8e9264 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -19,7 +19,7 @@ struct netlink_skb_parms {
 	struct scm_creds	creds;		/* Skb credentials	*/
 	__u32			portid;
 	__u32			dst_group;
-	struct sock		*ssk;
+	struct sock		*sk;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 8620408..5f64875 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -324,7 +324,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	}
 
 	err = sk_diag_fill(sk, rep, req,
-			   sk_user_ns(NETLINK_CB(in_skb).ssk),
+			   sk_user_ns(NETLINK_CB(in_skb).sk),
 			   NETLINK_CB(in_skb).portid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
@@ -630,7 +630,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 		return 0;
 
 	return inet_csk_diag_fill(sk, skb, r,
-				  sk_user_ns(NETLINK_CB(cb->skb).ssk),
+				  sk_user_ns(NETLINK_CB(cb->skb).sk),
 				  NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -805,7 +805,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			}
 
 			err = inet_diag_fill_req(skb, sk, req,
-					       sk_user_ns(NETLINK_CB(cb->skb).ssk),
+					       sk_user_ns(NETLINK_CB(cb->skb).sk),
 					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, cb->nlh);
 			if (err < 0) {
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 369a781..7927db0 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -25,7 +25,7 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 		return 0;
 
 	return inet_sk_diag_fill(sk, NULL, skb, req,
-			sk_user_ns(NETLINK_CB(cb->skb).ssk),
+			sk_user_ns(NETLINK_CB(cb->skb).sk),
 			NETLINK_CB(cb->skb).portid,
 			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
@@ -71,7 +71,7 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 		goto out;
 
 	err = inet_sk_diag_fill(sk, NULL, rep, req,
-			   sk_user_ns(NETLINK_CB(in_skb).ssk),
+			   sk_user_ns(NETLINK_CB(in_skb).sk),
 			   NETLINK_CB(in_skb).portid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 1a0be2a..50aaf71 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -824,7 +824,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 
 			inst = instance_create(net, group_num,
 					       NETLINK_CB(skb).portid,
-					       sk_user_ns(NETLINK_CB(skb).ssk));
+					       sk_user_ns(NETLINK_CB(skb).sk));
 			if (IS_ERR(inst)) {
 				ret = PTR_ERR(inst);
 				goto out;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f20a810..978a61f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -891,7 +891,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 	if (nlk->netlink_rcv != NULL) {
 		ret = skb->len;
 		skb_set_owner_r(skb, sk);
-		NETLINK_CB(skb).ssk = ssk;
+		NETLINK_CB(skb).sk = ssk;
 		nlk->netlink_rcv(skb);
 		consume_skb(skb);
 	} else {
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index aa36a8c..7881e2f 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -393,7 +393,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 
 		if ((keymask & (FLOW_KEY_SKUID|FLOW_KEY_SKGID)) &&
-		    sk_user_ns(NETLINK_CB(in_skb).ssk) != &init_user_ns)
+		    sk_user_ns(NETLINK_CB(in_skb).sk) != &init_user_ns)
 			return -EOPNOTSUPP;
 	}
 
-- 
1.8.1.4
