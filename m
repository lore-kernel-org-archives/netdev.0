From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: fix real_num_tx_queues update issue
Date: Wed, 17 Feb 2010 04:36:28 -0800
Message-ID: <20100217123627.18210.43584.stgit@localhost.localdomain>
References: <20100217123606.18210.13602.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:35639
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752609Ab0BQMgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 07:36:46 -0500
In-Reply-To: <20100217123606.18210.13602.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Currently netdev_features_change is called before fcoe tx queues
setup is done, so this patch moves calling of netdev_features_change
after tx queues setup is done in ixgbe_init_interrupt_scheme, so
that real_num_tx_queues is updated correctly on each fcoe enable
and disable.

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

