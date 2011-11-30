From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 09/12] [IEEE802154] ieee802154: type of device to be added
Date: Wed, 30 Nov 2011 17:26:21 +0300
Message-ID: <1322663181-4058-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33208 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab1K3N0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:26:43 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so664542eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 05:26:42 -0800 (PST)
In-Reply-To: <20111130141827.GA3739@avtobot.cybertron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device type argument is added to callback which creates interface.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 include/net/wpan-phy.h  |    2 +-
 net/ieee802154/nl-phy.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/wpan-phy.h b/include/net/wpan-phy.h
index d86fffd..0c2c931 100644
--- a/include/net/wpan-phy.h
+++ b/include/net/wpan-phy.h
@@ -42,7 +42,7 @@ struct wpan_phy {
 	int idx;
 
 	struct net_device *(*add_iface)(struct wpan_phy *phy,
-			const char *name);
+			const char *name, int type);
 	void (*del_iface)(struct wpan_phy *phy, struct net_device *dev);
 
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index c64a38d..0c02fcf 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -179,6 +179,7 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 	const char *devname;
 	int rc = -ENOBUFS;
 	struct net_device *dev;
+        int type = -EINVAL;
 
 	pr_debug("%s\n", __func__);
 
@@ -221,7 +222,7 @@ static int ieee802154_add_iface(struct sk_buff *skb,
 		goto nla_put_failure;
 	}
 
-	dev = phy->add_iface(phy, devname);
+	dev = phy->add_iface(phy, devname, type);
 	if (IS_ERR(dev)) {
 		rc = PTR_ERR(dev);
 		goto nla_put_failure;
-- 
1.7.2.3
