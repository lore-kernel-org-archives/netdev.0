From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next v2] net: Add GSO to vlan_features initialization
Date: Wed, 06 Jul 2011 10:09:08 +0800
Message-ID: <4E13C3C4.40809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	=?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59049 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755838Ab1GFCH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 22:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just add GSO to vlan_features initialization, and update comments.

When we set offload features, vlan_dev_fix_features() will do more check.
In vlan_dev_fix_features(), final features is decided by
features of real device and vlan_features of real device.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
v2: update changelog.

---
 net/core/dev.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4577e67..9ca1514 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5488,11 +5488,12 @@ int register_netdevice(struct net_device *dev)
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
