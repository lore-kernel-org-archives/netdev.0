From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 13/29: ctnetlink: use EOPNOTSUPP instead of EINVAL if the conntrack	has no helper
Date: Thu, 27 Nov 2008 17:15:21 +0100 (MET)
Message-ID: <20081127161520.13891.58312.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53376 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbYK0QPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:21 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit bfe2967735e0e0f650bf698a5683db2b6cf4cfd7
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Nov 17 15:55:48 2008 +0100

    netfilter: ctnetlink: use EOPNOTSUPP instead of EINVAL if the conntrack	has no helper
    
    This patch changes the return value if the conntrack has no helper assigned.
    Instead of EINVAL, which is reserved for malformed messages, it returns
    EOPNOTSUPP.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 80a3f13..d87a939 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1652,7 +1652,7 @@ ctnetlink_create_expect(struct nlattr *cda[], u_int8_t u3)
 
 	if (!help || !help->helper) {
 		/* such conntrack hasn't got any helper, abort */
-		err = -EINVAL;
+		err = -EOPNOTSUPP;
 		goto out;
 	}
 
