From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] ematch: oops from uninitialized variable (resend)
Date: Fri, 8 Feb 2008 17:54:16 -0800
Message-ID: <20080208175416.50ccdfaa@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41359 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751332AbYBIB4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 20:56:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting up a meta match causes a kernel OOPS because of uninitialized
elements in tree.

[   37.322381] BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
[   37.322381] IP: [<ffffffff883fc717>] :em_meta:em_meta_destroy+0x17/0x80

[   37.322381] Call Trace:
[   37.322381]  [<ffffffff803ec83d>] tcf_em_tree_destroy+0x2d/0xa0
[   37.322381]  [<ffffffff803ecc8c>] tcf_em_tree_validate+0x2dc/0x4a0
[   37.322381]  [<ffffffff803f06d2>] nla_parse+0x92/0xe0
[   37.322381]  [<ffffffff883f9672>] :cls_basic:basic_change+0x202/0x3c0
[   37.322381]  [<ffffffff802a3917>] kmem_cache_alloc+0x67/0xa0
[   37.322381]  [<ffffffff803ea221>] tc_ctl_tfilter+0x3b1/0x580
[   37.322381]  [<ffffffff803dffd0>] rtnetlink_rcv_msg+0x0/0x260
[   37.322381]  [<ffffffff803ee944>] netlink_rcv_skb+0x74/0xa0
[   37.322381]  [<ffffffff803dffc8>] rtnetlink_rcv+0x18/0x20
[   37.322381]  [<ffffffff803ee6c3>] netlink_unicast+0x263/0x290
[   37.322381]  [<ffffffff803cf276>] __alloc_skb+0x96/0x160
[   37.322381]  [<ffffffff803ef014>] netlink_sendmsg+0x274/0x340
[   37.322381]  [<ffffffff803c7c3b>] sock_sendmsg+0x12b/0x140
[   37.322381]  [<ffffffff8024de90>] autoremove_wake_function+0x0/0x30
[   37.322381]  [<ffffffff8024de90>] autoremove_wake_function+0x0/0x30
[   37.322381]  [<ffffffff803c7c3b>] sock_sendmsg+0x12b/0x140
[   37.322381]  [<ffffffff80288611>] zone_statistics+0xb1/0xc0
[   37.322381]  [<ffffffff803c7e5e>] sys_sendmsg+0x20e/0x360
[   37.322381]  [<ffffffff803c7411>] sockfd_lookup_light+0x41/0x80
[   37.322381]  [<ffffffff8028d04b>] handle_mm_fault+0x3eb/0x7f0
[   37.322381]  [<ffffffff8020c2fb>] system_call_after_swapgs+0x7b/0x80


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/sched/ematch.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 74ff918..d421ec7 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -312,10 +312,9 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 	struct tcf_ematch_tree_hdr *tree_hdr;
 	struct tcf_ematch *em;
 
-	if (!nla) {
-		memset(tree, 0, sizeof(*tree));
+	memset(tree, 0, sizeof(*tree));
+	if (!nla)
 		return 0;
-	}
 
 	err = nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, em_policy);
 	if (err < 0

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
