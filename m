From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nf_ct_expect: Change __nf_ct_expect_check() return value.
Date: Mon, 27 Feb 2017 12:35:41 +0100
Message-ID: <1488195342-2678-6-git-send-email-pablo@netfilter.org>
References: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48532 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751998AbdB0Lgo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 06:36:44 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 90C91E64D
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7F6E7DA81C
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4B048DA807
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:57 +0100 (CET)
In-Reply-To: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Commit 4dee62b1b9b4 ("netfilter: nf_ct_expect: nf_ct_expect_insert()
returns void") inadvertently changed the successful return value of
nf_ct_expect_related_report() from 0 to 1 due to
__nf_ct_expect_check() returning 1 on success.  Prevent this
regression in the future by changing the return value of
__nf_ct_expect_check() to 0 on success.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index d6ace69d57dc..4b2e1fb28bb4 100644
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
