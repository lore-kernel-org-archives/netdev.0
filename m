From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] rtnl: do not include num_rx_queues into msg when CONFIG_RPS is not set
Date: Sun, 22 Jul 2012 09:26:42 +0200
Message-ID: <1342942002-26731-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfr@canb.auug.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:54629 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab2GVH0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 03:26:55 -0400
Received: by wgbdr13 with SMTP id dr13so4862480wgb.1
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 00:26:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5bb1ebc..334b930 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -892,7 +892,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u32(skb, IFLA_GROUP, dev->group) ||
 	    nla_put_u32(skb, IFLA_PROMISCUITY, dev->promiscuity) ||
 	    nla_put_u32(skb, IFLA_NUM_TX_QUEUES, dev->num_tx_queues) ||
+#ifdef CONFIG_RPS
 	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
+#endif
 	    (dev->ifindex != dev->iflink &&
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
 	    (dev->master &&
-- 
1.7.10.4
