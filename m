From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] ixgbe: Support sending custom Ethernet FCS.
Date: Sat, 17 Mar 2012 01:50:51 -0700
Message-ID: <1331974260-6383-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51651 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755843Ab2CQIva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:30 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Including bad FCS, used generate frames with bad FCS
to test other system's handling of RX of bad packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 167e898..986897b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6768,6 +6768,8 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		tx_buffer_info->dma = dma;
 
 		tx_desc->read.buffer_addr = cpu_to_le64(dma + offset);
+		if (unlikely(skb->no_fcs))
+			cmd_type &= ~(cpu_to_le32(IXGBE_ADVTXD_DCMD_IFCS));
 		tx_desc->read.cmd_type_len = cmd_type | cpu_to_le32(size);
 		tx_desc->read.olinfo_status = olinfo_status;
 
@@ -7778,6 +7780,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_SG;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
-- 
1.7.7.6
