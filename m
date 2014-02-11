From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 17:36:33 -0800
Message-ID: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:40955 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaBKBgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:36:37 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so6962366pab.17
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 17:36:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691

There is no point to allow moving a macvlan device to
another namespace while the lower device is still in
this namespace. tunnels already set this flag.

Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 8433de4..9bc3b13 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -539,7 +539,7 @@ static int macvlan_init(struct net_device *dev)
 	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
-	dev->features		|= NETIF_F_LLTX;
+	dev->features		|= NETIF_F_LLTX | NETIF_F_NETNS_LOCAL;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->iflink		= lowerdev->ifindex;
 	dev->hard_header_len	= lowerdev->hard_header_len;
@@ -699,7 +699,7 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 	features = netdev_increment_features(vlan->lowerdev->features,
 					     features,
 					     mask);
-	features |= NETIF_F_LLTX;
+	features |= NETIF_F_LLTX | NETIF_F_NETNS_LOCAL;
 
 	return features;
 }
