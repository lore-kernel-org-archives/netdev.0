From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: Fix ndo_setup_tc comment
Date: Thu, 26 Jan 2017 14:44:17 -0800
Message-ID: <20170126224417.10327-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, john.r.fastabend@intel.com, jiri@mellanox.com,
        jhs@mojatatu.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35623 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbdAZWoe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:44:34 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so17249811pfa.2
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:44:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 16e5cc647173 ("net: rework setup_tc ndo op to consume
general tc operand") changed the ndo_setup_tc() signature, but did not
update the comments in netdevice.h, so do that now.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3868c32d98af..d63cacb67ea6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -964,11 +964,12 @@ struct netdev_xdp {
  *      with PF and querying it may introduce a theoretical security risk.
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
- * int (*ndo_setup_tc)(struct net_device *dev, u8 tc)
- * 	Called to setup 'tc' number of traffic classes in the net device. This
- * 	is always called from the stack with the rtnl lock held and netif tx
- * 	queues stopped. This allows the netdevice to perform queue management
- * 	safely.
+ * int (*ndo_setup_tc)(struct net_device *dev, u32 handle,
+ *		       __be16 protocol, struct tc_to_netdev *tc);
+ *	Called to setup any 'tc' scheduler, classifier or action on @dev.
+ *	This is always called from the stack with the rtnl lock held and netif
+ *	tx queues stopped. This allows the netdevice to perform queue
+ *	management safely.
  *
  *	Fiber Channel over Ethernet (FCoE) offload functions.
  * int (*ndo_fcoe_enable)(struct net_device *dev);
-- 
2.9.3
