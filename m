From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 02/12] ixgbe: updates vlan feature flags to enable
	FCoE offloads on vlan interface
Date: Fri, 14 Aug 2009 15:41:28 -0700
Message-ID: <20090814224127.1640.84665.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Vasu Dev <vasu.dev@intel.com>,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasu Dev <vasu.dev@intel.com>

Updates netdev->vlan_features for NETIF_F_FCOE_CRC and NETIF_F_FSO, so that
FCoE CRC and GSO offloads will get used for FCoE over ixgbe based vlan
interface.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 1c72657..116f12c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -148,7 +148,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 				IXGBE_FCRETA_SIZE;
 			netdev->features |= NETIF_F_FCOE_CRC;
 			netdev->features |= NETIF_F_FSO;
+			netdev->vlan_features |= NETIF_F_FCOE_CRC;
+			netdev->vlan_features |= NETIF_F_FSO;
 			netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
+			netdev_features_change(netdev);
 		}
 #endif /* IXGBE_FCOE */
 		ixgbe_init_interrupt_scheme(adapter);
@@ -177,7 +180,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 				adapter->ring_feature[RING_F_FCOE].indices = 0;
 				netdev->features &= ~NETIF_F_FCOE_CRC;
 				netdev->features &= ~NETIF_F_FSO;
+				netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
+				netdev->vlan_features &= ~NETIF_F_FSO;
 				netdev->fcoe_ddp_xid = 0;
+				netdev_features_change(netdev);
 			}
 #endif /* IXGBE_FCOE */
 			ixgbe_init_interrupt_scheme(adapter);

