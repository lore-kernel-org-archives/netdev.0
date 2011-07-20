From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 42/47] qlcnic: remove usage of vlan_group_get_device
Date: Wed, 20 Jul 2011 16:54:44 +0200
Message-ID: <1311173689-17419-43-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	amit.salecha@qlogic.com, anirban.chakraborty@qlogic.com,
	linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1GTO4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:12 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3579229..5ca1b56 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -4198,18 +4198,13 @@ static void
 qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct vlan_group *grp;
 	struct net_device *dev;
 	u16 vid;
 
 	qlcnic_config_indev_addr(adapter, netdev, event);
 
-	grp = rcu_dereference_rtnl(netdev->vlgrp);
-	if (!grp)
-		return;
-
 	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
-		dev = vlan_group_get_device(grp, vid);
+		dev = __vlan_find_dev_deep(netdev, vid);
 		if (!dev)
 			continue;
 		qlcnic_config_indev_addr(adapter, dev, event);
-- 
1.7.6

