From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: macvlan: Remove duplicated IFF_UP condition check in macvlan_forward_source_one
Date: Sun, 20 Nov 2016 19:21:19 +0800
Message-ID: <1479640879-30733-1-git-send-email-fgao@ikuai8.com>
To: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg340.qq.com ([14.17.44.35]:45588 "EHLO smtpbg340.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753366AbcKTLWt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Nov 2016 06:22:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

The condition check "dev->flags & IFF_UP" is duplicated in
macvlan_forward_source_one, because its caller macvlan_forward_source
has already checked this flag.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 drivers/net/macvlan.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 13b7e0b..95a5ffc 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -375,9 +375,6 @@ static void macvlan_forward_source_one(struct sk_buff *skb,
 	int ret;
 
 	dev = vlan->dev;
-	if (unlikely(!(dev->flags & IFF_UP)))
-		return;
-
 	nskb = skb_clone(skb, GFP_ATOMIC);
 	if (!nskb)
 		return;
-- 
1.9.1
