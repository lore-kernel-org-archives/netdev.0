From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH v2 net-next 5/7] mac802154: mlme start request
Date: Tue, 26 Jun 2012 13:24:52 +0400
Message-ID: <1340702694-24706-6-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42562 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324Ab2FZJ3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:29:13 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so5026840wgb.1
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 02:29:12 -0700 (PDT)
In-Reply-To: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basic preparations to start the interface.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/mac802154/mac_cmd.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index db83419..7f5403e 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -25,12 +25,36 @@
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 
+#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
 #include <net/mac802154.h>
+#include <net/nl802154.h>
 
 #include "mac802154.h"
 
+static int mac802154_mlme_start_req(struct net_device *dev,
+				    struct ieee802154_addr *addr,
+				    u8 channel, u8 page,
+				    u8 bcn_ord, u8 sf_ord,
+				    u8 pan_coord, u8 blx,
+				    u8 coord_realign)
+{
+	BUG_ON(addr->addr_type != IEEE802154_ADDR_SHORT);
+
+	mac802154_dev_set_pan_id(dev, addr->pan_id);
+	mac802154_dev_set_short_addr(dev, addr->short_addr);
+	mac802154_dev_set_ieee_addr(dev);
+	mac802154_dev_set_page_channel(dev, page, channel);
+
+	/* FIXME: add validation for unused parameters to be sane
+	 * for SoftMAC
+	 */
+	ieee802154_nl_start_confirm(dev, IEEE802154_SUCCESS);
+
+	return 0;
+}
+
 struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
 {
 	struct mac802154_sub_if_data *priv = netdev_priv(dev);
@@ -46,4 +70,5 @@ struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced = {
 
 struct ieee802154_mlme_ops mac802154_mlme_wpan = {
 	.get_phy = mac802154_get_phy,
+	.start_req = mac802154_mlme_start_req,
 };
-- 
1.7.2.3
