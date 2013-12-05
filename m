From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net] vxlan: release rt when found circular route
Date: Thu, 5 Dec 2013 16:03:51 +0800
Message-ID: <1386230631-2504-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65394 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737Ab3LEIDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 03:03:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise causing dst memory leakage.
Have Checked all other type tunnel device transmit implementation,
no such things happens anymore.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 drivers/net/vxlan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 78df8f3..97b4340 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1665,6 +1665,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		if (rt->dst.dev == dev) {
+			ip_rt_put(rt);
 			netdev_dbg(dev, "circular route to %pI4\n",
 				   &dst->sin.sin_addr.s_addr);
 			dev->stats.collisions++;
-- 
1.7.9.5
