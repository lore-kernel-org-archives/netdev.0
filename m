From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 04/11] nf_conntrack_netlink: pass nf_conntrack_netlink module to netlink_dump_start
Date: Wed, 26 Sep 2012 12:52:13 +0800
Message-ID: <1348635140-20225-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, steffen.klassert@secunet.com,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:27694 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751323Ab2IZEwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 00:52:49 -0400
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use proper netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_netlink.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9807f32..509a257 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -706,6 +706,7 @@ static int ctnetlink_done(struct netlink_callback *cb)
 		nf_ct_put((struct nf_conn *)cb->args[1]);
 	if (cb->data)
 		kfree(cb->data);
+	netlink_dump_done(cb);
 	return 0;
 }
 
@@ -1022,6 +1023,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_dump_table,
 			.done = ctnetlink_done,
+			.module = THIS_MODULE,
 		};
 #ifdef CONFIG_NF_CONNTRACK_MARK
 		if (cda[CTA_MARK] && cda[CTA_MARK_MASK]) {
@@ -1706,6 +1708,8 @@ ctnetlink_stat_ct_cpu(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_ct_stat_cpu_dump,
+			.done = netlink_dump_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
@@ -2141,6 +2145,7 @@ static int ctnetlink_exp_done(struct netlink_callback *cb)
 {
 	if (cb->args[1])
 		nf_ct_expect_put((struct nf_conntrack_expect *)cb->args[1]);
+	netlink_dump_done(cb);
 	return 0;
 }
 
@@ -2222,6 +2227,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_exp_dump_table,
 			.done = ctnetlink_exp_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
@@ -2660,6 +2666,8 @@ ctnetlink_stat_exp_cpu(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		struct netlink_dump_control c = {
 			.dump = ctnetlink_exp_stat_cpu_dump,
+			.done = netlink_dump_done,
+			.module = THIS_MODULE,
 		};
 		return netlink_dump_start(ctnl, skb, nlh, &c);
 	}
-- 
1.7.7.6
