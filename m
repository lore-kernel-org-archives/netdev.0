From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH nf] netfilter: xt_LOG: fix mark logging for IPv6 packets
Date: Wed, 29 May 2013 10:37:03 +0200
Message-ID: <20130529084118.6676862C72@unicorn.suse.cz>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, coreteam@netfilter.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44878 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965069Ab3E2IlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 04:41:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dump_ipv6_packet(), the "recurse" parameter is zero only if
dumping contents of a packet embedded into an ICMPv6 error
message. Therefore we want to log packet mark if recurse is
non-zero, not when it is zero.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/netfilter/xt_LOG.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 491c7d8..5ab2484 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -737,7 +737,7 @@ static void dump_ipv6_packet(struct sbuff *m,
 		dump_sk_uid_gid(m, skb->sk);
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
-	if (!recurse && skb->mark)
+	if (recurse && skb->mark)
 		sb_add(m, "MARK=0x%x ", skb->mark);
 }
 
-- 
1.8.1.4
