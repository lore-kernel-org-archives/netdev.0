From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] bonding: Don't allow bond devices to change network namespaces.
Date: Wed, 22 Jan 2014 17:16:30 +0800
Message-ID: <1390382190-1604-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:47333 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbaAVJRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 04:17:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Like bridge, bonding as netdevice doesn't cross netns boundaries.

Bonding ports and bonding itself live in same netns.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f00dd45..897d153 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3916,6 +3916,9 @@ void bond_setup(struct net_device *bond_dev)
 	 * capable
 	 */
 
+	/* Don't allow bond devices to change network namespaces. */
+	bond_dev->features |= NETIF_F_NETNS_LOCAL;
+
 	bond_dev->hw_features = BOND_VLAN_FEATURES |
 				NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_CTAG_RX |
-- 
1.7.12
