From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 6/7] xfrm: Use l3_dev for xfrm policy checks.
Date: Wed,  9 Mar 2016 13:50:12 -0800
Message-ID: <1457560212-13289-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33622 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934194AbcCIVuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:50:15 -0500
Received: by mail-pf0-f195.google.com with SMTP id 129so1838279pfw.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:50:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

IPsec, whether it's tunnel mode or transport mode, is still a
function of L3 so all the decisions should be based on the L3
device.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 include/net/xfrm.h     | 2 +-
 net/xfrm/xfrm_policy.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d6f6e5006ee9..30f9a351c3b9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1067,7 +1067,7 @@ static inline int __xfrm_policy_check2(struct sock *sk, int dir,
 				       struct sk_buff *skb,
 				       unsigned int family, int reverse)
 {
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(netif_get_l3_dev(skb->dev));
 	int ndir = dir | (reverse ? XFRM_POLICY_MASK + 1 : 0);
 
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b3cfb0..c5942744f2e3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2462,7 +2462,7 @@ static inline int secpath_has_nontransport(const struct sec_path *sp, int k, int
 int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 			unsigned short family)
 {
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(netif_get_l3_dev(skb->dev));
 	struct xfrm_policy *pol;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int npols = 0;
@@ -2620,7 +2620,7 @@ EXPORT_SYMBOL(__xfrm_policy_check);
 
 int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(netif_get_l3_dev(skb->dev));
 	struct flowi fl;
 	struct dst_entry *dst;
 	int res = 1;
-- 
2.7.0.rc3.207.g0ac5344
