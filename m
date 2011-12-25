From: pablo@netfilter.org
Subject: [PATCH 07/19] netfilter: ctnetlink: use expect instead of master tuple in get operation
Date: Sun, 25 Dec 2011 02:57:23 +0100
Message-ID: <1324778255-2830-8-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55991 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757985Ab1LYB6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 20:58:00 -0500
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Use the expect tuple (if possible) instead of the master tuple for
the get operation. If two or more expectations come from the same
master, the returned expectation may not be the one that user-space
is requesting.

This is how it works for the expect deletion operation.

Although I think that nobody has been seriously using this. We
accept both possibilities, using the expect tuple if possible.
I decided to do it like this to avoid breaking backward
compatibility.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a36e655..77d209c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1851,7 +1851,9 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	if (cda[CTA_EXPECT_MASTER])
+	if (cda[CTA_EXPECT_TUPLE])
+		err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE, u3);
+	else if (cda[CTA_EXPECT_MASTER])
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_MASTER, u3);
 	else
 		return -EINVAL;
-- 
1.7.2.5
