From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] net: More vlan tests before registering netdevice
Date: Wed, 31 Dec 2014 08:35:36 +0200
Message-ID: <1420007736-30822-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:49558 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750710AbaLaGfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 01:35:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When register_netdevice() is called, netdevice's vlan filtering feature
and supplied callbacks are checked to see the vlan implementation is
not buggy.
This adds an additional test - see that the vlan_features were filled
correctly, as the vlan devices inherits those as its own features;
Incorrect values set there would later prevent the vlan interface from being
registered itself [as it doesn't implement the filtering ndos].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Not sure why take such a defensive approach regarding this feature.
Perhaps it would have been better to simply remove these checks altogether.

Cheers,
Yuval
---

 net/core/dev.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3f191da..8a663b2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6253,10 +6253,11 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	if (((dev->hw_features | dev->features) &
-	     NETIF_F_HW_VLAN_CTAG_FILTER) &&
-	    (!dev->netdev_ops->ndo_vlan_rx_add_vid ||
-	     !dev->netdev_ops->ndo_vlan_rx_kill_vid)) {
+	if ((((dev->hw_features | dev->features) &
+	      NETIF_F_HW_VLAN_CTAG_FILTER) &&
+	     (!dev->netdev_ops->ndo_vlan_rx_add_vid ||
+	      !dev->netdev_ops->ndo_vlan_rx_kill_vid)) ||
+	    (dev->vlan_features & NETIF_F_HW_VLAN_CTAG_FILTER) {
 		netdev_WARN(dev, "Buggy VLAN acceleration in driver!\n");
 		ret = -EINVAL;
 		goto err_uninit;
-- 
1.9.3
