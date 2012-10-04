From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [patch v3 04/11] nf_conntrack_netlink: pass nf_conntrack_netlink module to netlink_dump_start
Date: Thu, 4 Oct 2012 12:41:22 +0800
Message-ID: <1349325689-16104-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	pablo@netfilter.org, stephen.hemminger@vyatta.com, jengelh@inai.de,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1349325689-16104-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set netlink_dump_control.module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_netlink.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 7bbfb3d..20af287 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1022,6 +1022,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_dump_table,
 			.done = ctnetlink_done,
+			.module = THIS_MODULE,
 		};
 #ifdef CONFIG_NF_CONNTRACK_MARK
 		if (cda[CTA_MARK] && cda[CTA_MARK_MASK]) {
@@ -1723,6 +1724,7 @@ ctnetlink_stat_ct_cpu(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_ct_stat_cpu_dump,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
@@ -2242,6 +2244,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_exp_dump_table,
 			.done = ctnetlink_exp_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
@@ -2680,6 +2683,7 @@ ctnetlink_stat_exp_cpu(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_exp_stat_cpu_dump,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
-- 
1.7.7.6

