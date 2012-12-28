From: pablo@netfilter.org
Subject: [PATCH 12/12] netfilter: ctnetlink: fix leak in error path of ctnetlink_create_expect
Date: Fri, 28 Dec 2012 12:52:51 +0100
Message-ID: <1356695571-3305-13-git-send-email-pablo@netfilter.org>
References: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51059 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab2L1Lx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 06:53:29 -0500
In-Reply-To: <1356695571-3305-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>

This patch fixes a leak in one of the error paths of
ctnetlink_create_expect if no helper and no timeout is specified.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4e078cd..627b0e5 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2624,7 +2624,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 	if (!help) {
 		if (!cda[CTA_EXPECT_TIMEOUT]) {
 			err = -EINVAL;
-			goto out;
+			goto err_out;
 		}
 		exp->timeout.expires =
 		  jiffies + ntohl(nla_get_be32(cda[CTA_EXPECT_TIMEOUT])) * HZ;
-- 
1.7.10.4
