From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] net: remove MTU limits for dummy and ifb device
Date: Fri, 22 Sep 2017 23:57:49 +0800
Message-ID: <1506095869-5465-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, sd@queasysnail.net, edumazet@google.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:3007 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbdIVP6f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 11:58:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two drivers (dummy and ifb) call ether_setup(), after commit
61e84623ace3 ("net: centralize net_device min/max MTU checking"), the
range of mtu is [min_mtu, max_mtu], which is [68, 1500] by default.

These two devices should not have limits on MTU. This patch set their
min_mtu/max_mtu to 0. So that dev_set_mtu() will not check the mtu range,
and can be set with any value.

CC: Eric Dumazet <edumazet@google.com>
CC: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/dummy.c | 2 +-
 drivers/net/ifb.c   | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index e31ab3b..58483af 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -353,7 +353,7 @@ static void dummy_setup(struct net_device *dev)
 	eth_hw_addr_random(dev);
 
 	dev->min_mtu = 0;
-	dev->max_mtu = ETH_MAX_MTU;
+	dev->max_mtu = 0;
 }
 
 static int dummy_validate(struct nlattr *tb[], struct nlattr *data[],
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 8870bd2..0008da7 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -231,6 +231,9 @@ static void ifb_setup(struct net_device *dev)
 	eth_hw_addr_random(dev);
 	dev->needs_free_netdev = true;
 	dev->priv_destructor = ifb_dev_free;
+
+	dev->min_mtu = 0;
+	dev->max_mtu = 0;
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.8.3.1
