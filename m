From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ieee802154: fix variable declaration and initializer
Date: Tue, 18 Mar 2014 21:19:58 -0600
Message-ID: <1395199198-14310-1-git-send-email-sakiwit@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:54484 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758942AbaCSDXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 23:23:31 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so8235359pbb.14
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 20:23:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 84dda3c648fd ("ieee802154: add support for
listen-before-talk in wpan_phy") introduced the new function
phy_set_lbt() with some minor issues in declaration and
initialization:

1) Fix the variable declaration by changing the type specifier to
   bool as that is the argument type when phy->set_lbt() is called.

2) Fix the initializer by deleting the double logical negation
   operators as they don't serve any purpose.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/nl-phy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 222310a07762..643dff07803b 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -379,9 +379,10 @@ static int phy_set_txpower(struct wpan_phy *phy, struct genl_info *info)
 
 static int phy_set_lbt(struct wpan_phy *phy, struct genl_info *info)
 {
-	u8 on = !!nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
+	bool on;
 	int rc;
 
+	on = nla_get_u8(info->attrs[IEEE802154_ATTR_LBT_ENABLED]);
 	rc = phy->set_lbt(phy, on);
 	if (rc < 0)
 		return rc;
