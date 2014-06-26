From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 2/2] mac802154: fix coding style issues
Date: Thu, 26 Jun 2014 19:06:55 +0530
Message-ID: <1403789815-10418-3-git-send-email-varkab@cdac.in>
References: <1403789815-10418-1-git-send-email-varkab@cdac.in>
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37089 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658AbaFZNia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 09:38:30 -0400
Received: by mail-pa0-f47.google.com with SMTP id kq14so3190287pab.6
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 06:38:29 -0700 (PDT)
In-Reply-To: <1403789815-10418-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 net/mac802154/ieee802154_dev.c |    4 +++-
 net/mac802154/llsec.c          |    1 +
 net/mac802154/mib.c            |    7 ++++---
 net/mac802154/tx.c             |    1 +
 4 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/mac802154/ieee802154_dev.c b/net/mac802154/ieee802154_dev.c
index 2cf66d8..c4d4568 100644
--- a/net/mac802154/ieee802154_dev.c
+++ b/net/mac802154/ieee802154_dev.c
@@ -143,6 +143,7 @@ static void
 mac802154_del_iface(struct wpan_phy *phy, struct net_device *dev)
 {
 	struct mac802154_sub_if_data *sdata;
+
 	ASSERT_RTNL();
 
 	sdata = netdev_priv(dev);
@@ -276,7 +277,8 @@ ieee802154_alloc_device(size_t priv_data_len, struct ieee802154_ops *ops)
 	}
 
 	priv = wpan_phy_priv(phy);
-	priv->hw.phy = priv->phy = phy;
+	priv->phy = phy;
+	priv->hw.phy = priv->phy;
 	priv->hw.priv = (char *)priv + ALIGN(sizeof(*priv), NETDEV_ALIGN);
 	priv->ops = ops;
 
diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 1456f73..4570581 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -538,6 +538,7 @@ static int llsec_recover_addr(struct mac802154_llsec *sec,
 			      struct ieee802154_addr *addr)
 {
 	__le16 caddr = sec->params.coord_shortaddr;
+
 	addr->pan_id = sec->params.pan_id;
 
 	if (caddr == cpu_to_le16(IEEE802154_ADDR_BROADCAST)) {
diff --git a/net/mac802154/mib.c b/net/mac802154/mib.c
index 15aa2f2..868a040 100644
--- a/net/mac802154/mib.c
+++ b/net/mac802154/mib.c
@@ -175,9 +175,9 @@ static void phy_chan_notify(struct work_struct *work)
 
 	mutex_lock(&priv->hw->phy->pib_lock);
 	res = hw->ops->set_channel(&hw->hw, priv->page, priv->chan);
-	if (res)
+	if (res) {
 		pr_debug("set_channel failed\n");
-	else {
+	} else {
 		priv->hw->phy->current_channel = priv->chan;
 		priv->hw->phy->current_page = priv->page;
 	}
@@ -210,8 +210,9 @@ void mac802154_dev_set_page_channel(struct net_device *dev, u8 page, u8 chan)
 		INIT_WORK(&work->work, phy_chan_notify);
 		work->dev = dev;
 		queue_work(priv->hw->dev_workqueue, &work->work);
-	} else
+	} else {
 		mutex_unlock(&priv->hw->phy->pib_lock);
+	}
 }
 
 
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 6d16473..8124353 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -98,6 +98,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 	if (!(priv->hw.flags & IEEE802154_HW_OMIT_CKSUM)) {
 		u16 crc = crc_ccitt(0, skb->data, skb->len);
 		u8 *data = skb_put(skb, 2);
+
 		data[0] = crc & 0xff;
 		data[1] = crc >> 8;
 	}
-- 
1.7.9.5
