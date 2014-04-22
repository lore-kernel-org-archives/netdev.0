From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next] vlan: Don't allow vlan devices to change network namespaces.
Date: Tue, 22 Apr 2014 20:43:06 +0800
Message-ID: <1398170586-6668-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33774 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbaDVMnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 08:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Like bonding, vlan as netdevice doesn't cross netns boundaries.

Vlan port and vlan itself live in same netns.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/8021q/vlan_dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 733ec28..2ef4a54 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -685,6 +685,9 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 	features |= old_features & NETIF_F_SOFT_FEATURES;
 	features |= NETIF_F_LLTX;
 
+	/* Don't allow vlan devices to change network namespaces. */
+	features |= NETIF_F_NETNS_LOCAL;
+
 	return features;
 }
 
-- 
1.7.12
