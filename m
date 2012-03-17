From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] igb: Support sending custom Ethernet FCS.
Date: Sat, 17 Mar 2012 01:50:49 -0700
Message-ID: <1331974260-6383-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56951 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213Ab2CQIv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:29 -0400
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
 drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e96cef8..99364ed 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1964,6 +1964,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 				 NETIF_F_IPV6_CSUM |
 				 NETIF_F_SG;
 
+	netdev->priv_flags |= IFF_SUPP_NOFCS;
+
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
 		netdev->vlan_features |= NETIF_F_HIGHDMA;
@@ -4293,6 +4295,8 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 
 	/* write last descriptor with RS and EOP bits */
 	cmd_type |= cpu_to_le32(size) | cpu_to_le32(IGB_TXD_DCMD);
+	if (unlikely(skb->no_fcs))
+		cmd_type &= ~(cpu_to_le32(E1000_ADVTXD_DCMD_IFCS));
 	tx_desc->read.cmd_type_len = cmd_type;
 
 	/* set the timestamp */
-- 
1.7.7.6
