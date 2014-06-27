From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bonding: allow to add vlans on top of empty bond
Date: Fri, 27 Jun 2014 16:13:12 +0200
Message-ID: <1403878392-10004-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:47171 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbaF0ONR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 10:13:17 -0400
Received: by mail-wg0-f41.google.com with SMTP id a1so5052357wgh.0
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 07:13:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This limitation maybe had some reason in the past, but now there is not
one -> removing this.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3a451b6..ffefb70 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1001,12 +1001,6 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 	netdev_features_t mask;
 	struct slave *slave;
 
-	if (!bond_has_slaves(bond)) {
-		/* Disable adding VLANs to empty bond. But why? --mq */
-		features |= NETIF_F_VLAN_CHALLENGED;
-		return features;
-	}
-
 	mask = features;
 	features &= ~NETIF_F_ONE_FOR_ALL;
 	features |= NETIF_F_ALL_FOR_ALL;
@@ -3956,13 +3950,6 @@ void bond_setup(struct net_device *bond_dev)
 	bond_dev->priv_flags |= IFF_BONDING | IFF_UNICAST_FLT;
 	bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 
-	/* At first, we block adding VLANs. That's the only way to
-	 * prevent problems that occur when adding VLANs over an
-	 * empty bond. The block will be removed once non-challenged
-	 * slaves are enslaved.
-	 */
-	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
-
 	/* don't acquire bond device's netif_tx_lock when
 	 * transmitting */
 	bond_dev->features |= NETIF_F_LLTX;
-- 
1.9.0
