From: greearb@candelatech.com
Subject: [PATCH 1/2] ixgbe: Support sending custom Ethernet FCS.
Date: Mon,  5 Mar 2012 17:18:23 -0800
Message-ID: <1330996704-13076-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40977 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757930Ab2CFBSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 20:18:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Including bad FCS, used generate frames with bad FCS
to test other system's handling of RX of bad packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 23a4665... b6e51f9... M	drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 23a4665..b6e51f9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6754,6 +6754,8 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		tx_buffer_info->dma = dma;
 
 		tx_desc->read.buffer_addr = cpu_to_le64(dma + offset);
+		if (unlikely(skb->no_fcs))
+			cmd_type &= ~(cpu_to_le32(IXGBE_ADVTXD_DCMD_IFCS));
 		tx_desc->read.cmd_type_len = cmd_type | cpu_to_le32(size);
 		tx_desc->read.olinfo_status = olinfo_status;
 
@@ -7762,6 +7764,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_SG;
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
 
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
-- 
1.7.3.4
