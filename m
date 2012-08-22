From: pablo@netfilter.org
Subject: [PATCH 08/10] netfilter: nf_conntrack: remove unnecessary RTNL locking
Date: Thu, 23 Aug 2012 01:38:44 +0200
Message-ID: <1345678726-3109-9-git-send-email-pablo@netfilter.org>
References: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:60192 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758076Ab2HWASs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 20:18:48 -0400
In-Reply-To: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Locking the rtnl was added to nf_conntrack_l{3,4}_proto_unregister()
for walking the network namespace list. This is not done anymore since
we have proper namespace support in the protocols now, so we don't
need to take the RTNL anymore.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 0dc6385..51e928d 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -21,7 +21,6 @@
 #include <linux/notifier.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/rtnetlink.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
@@ -294,9 +293,7 @@ void nf_conntrack_l3proto_unregister(struct net *net,
 	nf_ct_l3proto_unregister_sysctl(net, proto);
 
 	/* Remove all contrack entries for this protocol */
-	rtnl_lock();
 	nf_ct_iterate_cleanup(net, kill_l3proto, proto);
-	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
@@ -502,9 +499,7 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
 
 	/* Remove all contrack entries for this protocol */
-	rtnl_lock();
 	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
-	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-- 
1.7.10.4
