From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: Fix SR-IOV MTU warning
Date: Tue,  5 Feb 2013 02:02:28 -0800
Message-ID: <1360058548-18158-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19489 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930Ab3BEKDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:03:00 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects the fact that we were using 1522 to test for the
max frame size in ixgbe_change_mtu and 1518 in ixgbe_set_vf_lpe.  The
difference was the addition of VLAN_HLEN which we only need to add in the case
of computing a buffer size, but not a filter size.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Sibai Li <Sibai.li@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 2a61889..d268c7b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -92,8 +92,6 @@
  */
 #define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
 
-#define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
-
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGBE_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ef9cb0a..396e280 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4869,7 +4869,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	 */
 	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
 	    (adapter->hw.mac.type == ixgbe_mac_82599EB) &&
-	    (max_frame > MAXIMUM_ETHERNET_VLAN_SIZE))
+	    (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)))
 		e_warn(probe, "Setting MTU > 1500 will disable legacy VFs\n");
 
 	e_info(probe, "changing MTU from %d to %d\n", netdev->mtu, new_mtu);
-- 
1.7.11.7
