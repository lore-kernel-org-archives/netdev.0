From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] vlan: turn on unicast filtering on vlan device
Date: Thu, 18 Feb 2016 10:00:11 +0000
Message-ID: <1455789611-31803-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9339 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425917AbcBRJ7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 04:59:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently vlan device inherits unicast filtering flag from underlying
device. If underlying device doesn't support unicast filter, this will
put vlan device into promiscuous mode when it's stacked.

Tun on IFF_UNICAST_FLT on the vlan device in any case so that it does
not go into promiscuous mode needlessly. If underlying device does not
support unicast filtering, that device will enter promiscuous mode.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/8021q/vlan.c     | 1 -
 net/8021q/vlan_dev.c | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d2cd9de..69929c0 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -261,7 +261,6 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	 * hope the underlying device can handle it.
 	 */
 	new_dev->mtu = real_dev->mtu;
-	new_dev->priv_flags |= (real_dev->priv_flags & IFF_UNICAST_FLT);
 
 	vlan = vlan_dev_priv(new_dev);
 	vlan->vlan_proto = htons(ETH_P_8021Q);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ad5e2fd..055f0e9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -799,6 +799,7 @@ void vlan_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags		|= IFF_802_1Q_VLAN | IFF_NO_QUEUE;
+	dev->priv_flags		|= IFF_UNICAST_FLT;
 	dev->priv_flags		&= ~IFF_TX_SKB_SHARING;
 	netif_keep_dst(dev);
 
-- 
1.8.3.1
