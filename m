From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: [PATCH] arp: fixed -Wuninitialized compiler warning
Date: Wed, 24 May 2017 15:19:35 -0700
Message-ID: <20170524221935.11167-1-ihrachys@redhat.com>
Cc: Ihar Hrachyshka <ihrachys@redhat.com>, netdev@vger.kernel.org
To: davem@davemloft.net, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164390AbdEXWTn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 18:19:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7d472a59c0e5ec117220a05de6b370447fb6cb66 ("arp: always override
existing neigh entries with gratuitous ARP") introduced a compiler
warning:

net/ipv4/arp.c:880:35: warning: 'addr_type' may be used uninitialized in
this function [-Wmaybe-uninitialized]

While the code logic seems to be correct and doesn't allow the variable
to be used uninitialized, and the warning is not consistently
reproducible, it's still worth fixing it for other people not to waste
time looking at the warning in case it pops up in the build environment.
Yes, compiler is probably at fault, but we will need to accommodate.

Fixes: 7d472a59c0e5ec117220a05de6b370447fb6cb66
Signed-off-by: Ihar Hrachyshka <ihrachys@redhat.com>
---
 net/ipv4/arp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ae96e6f..e9f3386 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -863,8 +863,8 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	n = __neigh_lookup(&arp_tbl, &sip, dev, 0);
 
+	addr_type = -1;
 	if (n || IN_DEV_ARP_ACCEPT(in_dev)) {
-		addr_type = -1;
 		is_garp = arp_is_garp(net, dev, &addr_type, arp->ar_op,
 				      sip, tip, sha, tha);
 	}
-- 
2.9.4
