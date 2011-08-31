From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net: Initialize entire flowi struct
Date: Wed, 31 Aug 2011 12:05:03 -0400
Message-ID: <1314806703-5275-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:38601 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756610Ab1HaQXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 12:23:54 -0400
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id p7VG5CVl017412 for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 12:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The entire flowi struct needs to be initialized by afinfo->decode_session,
because flow_hash_code operates over the entire struct and may otherwise
return different hash values for what is intended to be the same key.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/xfrm6_policy.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index fc5368a..afce24d 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -114,7 +114,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 	struct flowi4 *fl4 = &fl->u.ip4;
 
-	memset(fl4, 0, sizeof(struct flowi4));
+	memset(fl, 0, sizeof(struct flowi));
 	fl4->flowi4_mark = skb->mark;
 
 	if (!ip_is_fragment(iph)) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d879f7e..9088d38 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -129,7 +129,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 
-	memset(fl6, 0, sizeof(struct flowi6));
+	memset(fl, 0, sizeof(struct flowi));
 	fl6->flowi6_mark = skb->mark;
 
 	ipv6_addr_copy(&fl6->daddr, reverse ? &hdr->saddr : &hdr->daddr);
-- 
1.7.4.1
