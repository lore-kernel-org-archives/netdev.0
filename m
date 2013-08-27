From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: ctnetlink: fix uninitialized variable
Date: Wed, 28 Aug 2013 00:53:38 +0200
Message-ID: <1377644018-15685-9-git-send-email-pablo@netfilter.org>
References: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44060 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656Ab3H0WyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:54:06 -0400
In-Reply-To: <1377644018-15685-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

net/netfilter/nf_conntrack_netlink.c: In function 'ctnetlink_nfqueue_attach_expect':
'helper' may be used uninitialized in this function

It was only initialized in if CTA_EXPECT_HELP_NAME attribute was
present, it must be NULL otherwise.

Problem added recently in bd077937
(netfilter: nfnetlink_queue: allow to attach expectations to conntracks).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 7c55745..eea936b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2162,7 +2162,7 @@ ctnetlink_nfqueue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
 {
 	struct nlattr *cda[CTA_EXPECT_MAX+1];
 	struct nf_conntrack_tuple tuple, mask;
-	struct nf_conntrack_helper *helper;
+	struct nf_conntrack_helper *helper = NULL;
 	struct nf_conntrack_expect *exp;
 	int err;
 
-- 
1.7.10.4
