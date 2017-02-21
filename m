From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next 2/2] netfilter: nf_ct_expect: Change __nf_ct_expect_check() return value.
Date: Tue, 21 Feb 2017 15:25:22 -0800
Message-ID: <1487719522-42844-2-git-send-email-jarno@ovn.org>
References: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, fgao@ikuai8.com, pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:56157 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752803AbdBUXZr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 18:25:47 -0500
In-Reply-To: <1487719522-42844-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4dee62b1 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
returns void") inadvertently changed the successful return value of
nf_ct_expect_related_report() from 0 to 1 due to
__nf_ct_expect_check() returning 1 on success.  Prevent this
regression in the future by changing the return value of
__nf_ct_expect_check() to 0 on success.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/netfilter/nf_conntrack_expect.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index d6ace69..4b2e1fb 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -410,7 +410,7 @@ static inline int __nf_ct_expect_check(struct nf_conntrack_expect *expect)
 	struct net *net = nf_ct_exp_net(expect);
 	struct hlist_node *next;
 	unsigned int h;
-	int ret = 1;
+	int ret = 0;
 
 	if (!master_help) {
 		ret = -ESHUTDOWN;
@@ -460,7 +460,7 @@ int nf_ct_expect_related_report(struct nf_conntrack_expect *expect,
 
 	spin_lock_bh(&nf_conntrack_expect_lock);
 	ret = __nf_ct_expect_check(expect);
-	if (ret <= 0)
+	if (ret < 0)
 		goto out;
 
 	nf_ct_expect_insert(expect);
-- 
2.1.4
