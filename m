From: "Mark A. Greer" <mgreer@animalcreek.com>
Subject: [PATCH] rtnl: Add #ifdef CONFIG_RPS around num_rx_queues reference
Date: Fri, 20 Jul 2012 16:35:13 -0700
Message-ID: <1342827313-2827-1-git-send-email-mgreer@animalcreek.com>
Cc: davem@davemloft.net, "Mark A. Greer" <mgreer@animalcreek.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail20.dotsterhost.com ([66.11.232.73]:41213 "EHLO
	mail20.dotsterhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab2GTXf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 19:35:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mark A. Greer" <mgreer@animalcreek.com>

Commit 76ff5cc91935c51fcf1a6a99ffa28b97a6e7a884
(rtnl: allow to specify number of rx and tx queues
on device creation) added a reference to the net_device
structure's 'num_rx_queues' member in

	net/core/rtnetlink.c:rtnl_fill_ifinfo()

However, the definition for 'num_rx_queues' is surrounded
by an '#ifdef CONFIG_RPS' while the new reference to it is
not.  This causes a compile error when CONFIG_RPS is not
defined.

Fix the compile error by surrounding the new reference to
'num_rx_queues' by an '#ifdef CONFIG_RPS'.

CC: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Mark A. Greer <mgreer@animalcreek.com>
---

The problem can be easily reproduced by compiling with
davinci_all_defconfig (ARCH=arm).  I don't know this
area well enough to know whether that (and other)
defconfigs should have CONFIG_RPS enabled or not, or
whether there is some missing Kconfig logic to enable
it.

 net/core/rtnetlink.c | 2 ++
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
1.7.11.2
