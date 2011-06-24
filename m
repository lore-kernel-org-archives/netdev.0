From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][NET-NEXT PATCH 2/2] net: Add GSO to vlan_features initialization
Date: Fri, 24 Jun 2011 11:38:38 +0800
Message-ID: <4E0406BE.50900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: =?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64135 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab1FXDho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 23:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is not a bug fix.
Just add GSO to vlan_features initialization, and update comments.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/core/dev.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6b6ef14..becc1e5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5478,11 +5478,12 @@ int register_netdevice(struct net_device *dev)
 		dev->features |= NETIF_F_NOCACHE_COPY;
 	}
 
-	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
-	 * vlan_dev_init() will do the dev->features check, so these features
-	 * are enabled only if supported by underlying device.
+	/* Enable GSO, GRO and NETIF_F_HIGHDMA for vlans by default,
+	 * vlan_dev_fix_features() will do the features check,
+	 * so NETIF_F_HIGHDMA feature is enabled only if supported
+	 * by underlying device.
 	 */
-	dev->vlan_features |= (NETIF_F_GRO | NETIF_F_HIGHDMA);
+	dev->vlan_features |= (NETIF_F_SOFT_FEATURES | NETIF_F_HIGHDMA);
 
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
-- 
1.7.4.1
