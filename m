From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix for real_num_tx_queues update issue
Date: Fri, 19 Mar 2010 07:33:10 -0700
Message-ID: <20100319143242.10230.9964.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:57100 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750921Ab0CSOd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 10:33:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Currently netdev_features_change is called before fcoe tx queues
setup is done, so this patch moves calling of netdev_features_change
after tx queues setup is done in ixgbe_init_interrupt_scheme, so
that real_num_tx_queues is updated correctly on each fcoe enable
or disable.

This allows additional fcoe queues updated correctly in vlan driver
for their correct queue selection.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 4123dec..700cfc0 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -614,9 +614,9 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 	netdev->vlan_features |= NETIF_F_FSO;
 	netdev->vlan_features |= NETIF_F_FCOE_MTU;
 	netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
-	netdev_features_change(netdev);
 
 	ixgbe_init_interrupt_scheme(adapter);
+	netdev_features_change(netdev);
 
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_open(netdev);
@@ -660,11 +660,11 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 	netdev->vlan_features &= ~NETIF_F_FSO;
 	netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
 	netdev->fcoe_ddp_xid = 0;
-	netdev_features_change(netdev);
 
 	ixgbe_cleanup_fcoe(adapter);
-
 	ixgbe_init_interrupt_scheme(adapter);
+	netdev_features_change(netdev);
+
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_open(netdev);
 	rc = 0;

