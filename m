From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] vlan: don't allow vlan device to move between network namespaces
Date: Fri, 28 Feb 2014 15:50:38 +0800
Message-ID: <1393573839-32316-2-git-send-email-dingtianhong@huawei.com>
References: <1393573839-32316-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <joe@perches.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <kaber@trash.net>, <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:57094 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaB1HvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 02:51:08 -0500
In-Reply-To: <1393573839-32316-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the vlan device could move to another network namespace, but
the read dev is sill in the old network namespace, it is unsafe
and the vlan device could not work well, so don't allow to do it.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlan_dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 566adbf..76d8fab 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -791,5 +791,8 @@ void vlan_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 	dev->ethtool_ops	= &vlan_ethtool_ops;
 
+	/* don't allow vlan device to move between network namespaces */
+	dev->features		|= NETIF_F_NETNS_LOCAL;
+
 	memset(dev->broadcast, 0, ETH_ALEN);
 }
-- 
1.8.0
