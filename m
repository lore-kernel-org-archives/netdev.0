From: pablo@netfilter.org
Subject: [PATCH 3/6] netfilter: ctnetlink: use GFP_ATOMIC in all allocations
Date: Tue,  6 Mar 2012 12:22:52 +0100
Message-ID: <1331032975-5303-4-git-send-email-pablo@netfilter.org>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

All ctnetlink operations are invoked inside rcu_read_lock
(see net/netfilter/nfnetlink.c).

Allocations have to be atomic, as RCU requires.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 1068769..867843f 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1002,7 +1002,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
 	err = -ENOMEM;
-	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (skb2 == NULL) {
 		nf_ct_put(ct);
 		return -ENOMEM;
@@ -1865,7 +1865,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	err = -ENOMEM;
-	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (skb2 == NULL) {
 		nf_ct_expect_put(exp);
 		goto out;
-- 
1.7.7.3

