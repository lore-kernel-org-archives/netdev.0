From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: macvlan: Remove duplicated IFF_UP condition check in macvlan_forward_source
Date: Mon, 21 Nov 2016 08:26:38 +0800
Message-ID: <1479687998-456-1-git-send-email-fgao@ikuai8.com>
To: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg327.qq.com ([14.17.43.158]:39238 "EHLO smtpbg327.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751490AbcKUAfb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Nov 2016 19:35:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

The function macvlan_forward_source_one has already checked the flag
IFF_UP, so needn't check it outside in macvlan_forward_source too.

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 v2: Remove the IFF_UP check in macvlan_forward_source instead of macvlan_forward_source_one
 v1: Initial patch

 drivers/net/macvlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 13b7e0b..7ddfd2c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -400,8 +400,7 @@ static void macvlan_forward_source(struct sk_buff *skb,
 
 	hlist_for_each_entry_rcu(entry, h, hlist) {
 		if (ether_addr_equal_64bits(entry->addr, addr))
-			if (entry->vlan->dev->flags & IFF_UP)
-				macvlan_forward_source_one(skb, entry->vlan);
+			macvlan_forward_source_one(skb, entry->vlan);
 	}
 }
 
-- 
1.9.1
