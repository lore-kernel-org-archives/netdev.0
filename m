From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] team: Don't allow team devices to change network namespaces.
Date: Thu, 23 Jan 2014 11:07:22 +0800
Message-ID: <1390446442-12768-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <jiri@resnulli.us>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:20278 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbaAWDII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 22:08:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Like bonding, team as netdevice doesn't cross netns boundaries.

Team ports and team itself live in same netns.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 drivers/net/team/team.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index dff24e3..2840742 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2034,6 +2034,10 @@ static void team_setup(struct net_device *dev)
 
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_GRO;
+
+	/* Don't allow team devices to change network namespaces. */
+	dev->features |= NETIF_F_NETNS_LOCAL;
+
 	dev->hw_features = TEAM_VLAN_FEATURES |
 			   NETIF_F_HW_VLAN_CTAG_TX |
 			   NETIF_F_HW_VLAN_CTAG_RX |
-- 
1.7.12
