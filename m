From: David Miller <davem@davemloft.net>
Subject: [PATCH 04/26] xfrm: Const'ify address arguments to ->dst_lookup()
Date: Wed, 23 Feb 2011 23:13:06 -0800 (PST)
Message-ID: <20110223.231306.112596457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37456
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755782Ab1BXHMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 02:12:30 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1B4DD24C088
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 23:13:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h      |    4 ++--
 net/ipv4/xfrm4_policy.c |    4 ++--
 net/ipv6/xfrm6_policy.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 567f08b..18f115a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -267,8 +267,8 @@ struct xfrm_policy_afinfo {
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(struct net *net);
 	struct dst_entry	*(*dst_lookup)(struct net *net, int tos,
-					       xfrm_address_t *saddr,
-					       xfrm_address_t *daddr);
+					       const xfrm_address_t *saddr,
+					       const xfrm_address_t *daddr);
 	int			(*get_saddr)(struct net *net, xfrm_address_t *saddr, xfrm_address_t *daddr);
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 1e9844d..63aa88e 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -19,8 +19,8 @@
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
 static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
-					  xfrm_address_t *saddr,
-					  xfrm_address_t *daddr)
+					  const xfrm_address_t *saddr,
+					  const xfrm_address_t *daddr)
 {
 	struct flowi fl = {
 		.fl4_dst = daddr->a4,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f2fa904..c128ca1 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -27,8 +27,8 @@
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
 static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
-					  xfrm_address_t *saddr,
-					  xfrm_address_t *daddr)
+					  const xfrm_address_t *saddr,
+					  const xfrm_address_t *daddr)
 {
 	struct flowi fl = {};
 	struct dst_entry *dst;
-- 
1.7.4.1

