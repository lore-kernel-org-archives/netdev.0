From: greearb@candelatech.com
Subject: [PATCH 1/2] igb: Support sending custom Ethernet FCS.
Date: Mon,  5 Mar 2012 17:30:40 -0800
Message-ID: <1330997441-13324-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57206 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758084Ab2CFBas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 20:30:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Including bad FCS, used generate frames with bad FCS
to test other system's handling of RX of bad packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 fda8247... e4058ac... M	drivers/net/ethernet/intel/igb/igb_main.c
 drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fda8247..e4058ac 100644
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
@@ -4292,6 +4294,8 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 
 	/* write last descriptor with RS and EOP bits */
 	cmd_type |= cpu_to_le32(size) | cpu_to_le32(IGB_TXD_DCMD);
+	if (unlikely(skb->no_fcs))
+		cmd_type &= ~(cpu_to_le32(E1000_ADVTXD_DCMD_IFCS));
 	tx_desc->read.cmd_type_len = cmd_type;
 
 	/* set the timestamp */
-- 
1.7.3.4
