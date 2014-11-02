From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next] netdevice: add ieee802154_ptr to net_device
Date: Sun,  2 Nov 2014 06:44:54 +0100
Message-ID: <1414907094-9623-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:57243 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbaKBFp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 01:45:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an ieee802154_ptr to the net_device structure.
Furthermore the 802.15.4 subsystem will introduce a nl802154 framework
which is similar like the nl80211 framework and a wpan_dev structure.
The wpan_dev structure will hold additional net_device attributes like
address options which are 802.15.4 specific. In the upcoming nl802154
implementation we will introduce a NL802154_FLAG_NEED_WPAN_DEV like
NL80211_FLAG_NEED_WDEV. For this flag an ieee802154_ptr in net_device is
needed. Additional we can access the wpan_dev attributes in upper layers
like IEEE 802.15.4 6LoWPAN easily. Current solution is a complicated
callback interface and getting these values over subif data structure
in mac802154.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
---
Another option would be to combine ieee80211_ptr and ieee802154_ptr in
an union. These pointer can't be used twice at the same time and the
union solution will not make the struct net_device bigger.

My working repository is bluetooth-next. Marcel will apply all 802.15.4
changes. That's why this patch should go into bluetooth-next. Then I can
send new patches which depends on this patch for introducing wpan_dev and
nl802154.

 include/linux/netdevice.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 74fd5d3..c9bcf33 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -57,6 +57,8 @@ struct device;
 struct phy_device;
 /* 802.11 specific */
 struct wireless_dev;
+/* 802.15.4 specific */
+struct wpan_dev;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -1572,6 +1574,7 @@ struct net_device {
 	struct inet6_dev __rcu	*ip6_ptr;
 	void			*ax25_ptr;
 	struct wireless_dev	*ieee80211_ptr;
+	struct wpan_dev		*ieee802154_ptr;
 
 /*
  * Cache lines mostly used on receive path (including eth_type_trans())
-- 
2.1.3
