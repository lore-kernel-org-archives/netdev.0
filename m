From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 3/7] mac802154: add get short address method
Date: Wed, 11 Jul 2012 11:22:44 +0400
Message-ID: <1341991368-11800-4-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56445 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756601Ab2GKH05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:26:57 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so656595wey.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:26:57 -0700 (PDT)
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add method to get the device short 802.15.4 address. This call
needed by ieee802154 layer to satisfy 'iz list' request from
the user space.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac802154.h |    1 +
 net/mac802154/mac_cmd.c   |    2 ++
 net/mac802154/mib.c       |   14 ++++++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 6967864..a4dcaf1 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -109,6 +109,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 
 /* MIB callbacks */
 void mac802154_dev_set_short_addr(struct net_device *dev, u16 val);
+u16 mac802154_dev_get_short_addr(const struct net_device *dev);
 void mac802154_dev_set_ieee_addr(struct net_device *dev);
 u16 mac802154_dev_get_pan_id(const struct net_device *dev);
 void mac802154_dev_set_pan_id(struct net_device *dev, u16 val);
diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index 7f5403e..5d9a47b 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -71,4 +71,6 @@ struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced = {
 struct ieee802154_mlme_ops mac802154_mlme_wpan = {
 	.get_phy = mac802154_get_phy,
 	.start_req = mac802154_mlme_start_req,
+	.get_pan_id = mac802154_dev_get_pan_id,
+	.get_short_addr = mac802154_dev_get_short_addr,
 };
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 380829d..5c66b8f 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -100,6 +100,20 @@ void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
 	}
 }
 
+u16 mac802154_dev_get_short_addr(const struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	u16 ret;
+
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	spin_lock_bh(&priv->mib_lock);
+	ret = priv->short_addr;
+	spin_unlock_bh(&priv->mib_lock);
+
+	return ret;
+}
+
 void mac802154_dev_set_ieee_addr(struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
-- 
1.7.2.3
