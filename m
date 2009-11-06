From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 07/17] ieee802154: constify struct net_device in some operations
Date: Fri,  6 Nov 2009 15:39:31 +0300
Message-ID: <1257511181-19403-8-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758084AbZKFMks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:48 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:53 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of ieee802154 operations really shouldn't change passed net_device.
Constify passed argument.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c   |    8 ++++----
 include/net/ieee802154_netdev.h |   10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 4ea93cc..77fbb51 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -43,7 +43,7 @@ struct wpan_phy *net_to_phy(struct net_device *dev)
  *
  * Return the ID of the PAN from the PIB.
  */
-static u16 fake_get_pan_id(struct net_device *dev)
+static u16 fake_get_pan_id(const struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
@@ -58,7 +58,7 @@ static u16 fake_get_pan_id(struct net_device *dev)
  * device. If the device has not yet had a short address assigned
  * then this should return 0xFFFF to indicate a lack of association.
  */
-static u16 fake_get_short_addr(struct net_device *dev)
+static u16 fake_get_short_addr(const struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
@@ -78,7 +78,7 @@ static u16 fake_get_short_addr(struct net_device *dev)
  * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
  *       document.
  */
-static u8 fake_get_dsn(struct net_device *dev)
+static u8 fake_get_dsn(const struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
@@ -98,7 +98,7 @@ static u8 fake_get_dsn(struct net_device *dev)
  * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
  *       document.
  */
-static u8 fake_get_bsn(struct net_device *dev)
+static u8 fake_get_bsn(const struct net_device *dev)
 {
 	BUG_ON(dev->type != ARPHRD_IEEE802154);
 
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 5dc6a61..d23fb5a 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -98,14 +98,14 @@ struct ieee802154_mlme_ops {
 	 * FIXME: these should become the part of PIB/MIB interface.
 	 * However we still don't have IB interface of any kind
 	 */
-	u16 (*get_pan_id)(struct net_device *dev);
-	u16 (*get_short_addr)(struct net_device *dev);
-	u8 (*get_dsn)(struct net_device *dev);
-	u8 (*get_bsn)(struct net_device *dev);
+	u16 (*get_pan_id)(const struct net_device *dev);
+	u16 (*get_short_addr)(const struct net_device *dev);
+	u8 (*get_dsn)(const struct net_device *dev);
+	u8 (*get_bsn)(const struct net_device *dev);
 };
 
 static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
-		struct net_device *dev)
+		const struct net_device *dev)
 {
 	return dev->ml_priv;
 }
-- 
1.6.5

