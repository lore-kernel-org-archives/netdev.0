From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [net-next-2.6 PATCH 4/5] ixgbe: Add support for
	NETIF_F_FCOE_MTU to	82599 devices
Date: Wed, 22 Jul 2009 16:29:32 -0700
Message-ID: <20090722232932.26937.44440.stgit@localhost.localdomain>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20090722232759.26937.78765.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Enable netdev feature flag bit NETIF_F_FCOE_MTU for 82599 devices and enable
jumbo frame correspondingly when NETIF_F_FCOE_MTU is set.

Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d89c695..2852a17 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2043,7 +2043,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	else
 		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
 #ifdef IXGBE_FCOE
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+	if (netdev->features & NETIF_F_FCOE_MTU)
 		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
 #endif
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
@@ -2070,7 +2070,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
 
 #ifdef IXGBE_FCOE
-		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+		if (netdev->features & NETIF_F_FCOE_MTU) {
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE) &&
@@ -2619,7 +2619,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 #ifdef IXGBE_FCOE
 	/* adjust max frame to be able to do baby jumbo for FCoE */
-	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	if ((netdev->features & NETIF_F_FCOE_MTU) &&
 	    (max_frame < IXGBE_FCOE_JUMBO_FRAME_SIZE))
 		max_frame = IXGBE_FCOE_JUMBO_FRAME_SIZE;
 
@@ -5588,8 +5588,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			if (!(device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)) {
 				netdev->features |= NETIF_F_FCOE_CRC;
 				netdev->features |= NETIF_F_FSO;
+				netdev->features |= NETIF_F_FCOE_MTU;
 				netdev->vlan_features |= NETIF_F_FCOE_CRC;
 				netdev->vlan_features |= NETIF_F_FSO;
+				netdev->vlan_features |= NETIF_F_FCOE_MTU;
 				netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
 			} else {
 				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
