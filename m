From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 3/4] geneve: Remove redundant socket checks.
Date: Thu, 17 Nov 2016 23:10:28 -0800
Message-ID: <1479453029-29619-4-git-send-email-pshelar@ovn.org>
References: <1479453029-29619-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:38449 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752149AbcKRHKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 02:10:40 -0500
In-Reply-To: <1479453029-29619-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geneve already has check for device socket in route
lookup function. So no need to check it in xmit
function.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/geneve.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 9a4351c..8e6c659 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -785,14 +785,11 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	struct geneve_sock *gs4 = rcu_dereference(geneve->sock4);
 	const struct ip_tunnel_key *key = &info->key;
 	struct rtable *rt;
-	int err = -EINVAL;
 	struct flowi4 fl4;
 	__u8 tos, ttl;
 	__be16 sport;
 	__be16 df;
-
-	if (!gs4)
-		return err;
+	int err;
 
 	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
 	if (IS_ERR(rt))
@@ -828,13 +825,10 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	struct geneve_sock *gs6 = rcu_dereference(geneve->sock6);
 	const struct ip_tunnel_key *key = &info->key;
 	struct dst_entry *dst = NULL;
-	int err = -EINVAL;
 	struct flowi6 fl6;
 	__u8 prio, ttl;
 	__be16 sport;
-
-	if (!gs6)
-		return err;
+	int err;
 
 	dst = geneve_get_v6_dst(skb, dev, &fl6, info);
 	if (IS_ERR(dst))
-- 
1.8.3.1
