From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: fix constant cast issues
Date: Sun,  5 Jan 2014 02:46:56 -0800
Message-ID: <1388918827-13430-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33338 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083AbaAEKrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:12 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Replace __constant_htons with htons

Change-Id: I123a5318bae34c8b004c71db07c56f137c685849
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a978451..2584d6b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1317,7 +1317,7 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 		tx_flags |= vlan_tx_tag_get(skb) << I40E_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= I40E_TX_FLAGS_HW_VLAN;
 	/* else if it is a SW VLAN, check the next protocol and store the tag */
-	} else if (protocol == __constant_htons(ETH_P_8021Q)) {
+	} else if (protocol == htons(ETH_P_8021Q)) {
 		struct vlan_hdr *vhdr, _vhdr;
 		vhdr = skb_header_pointer(skb, ETH_HLEN, sizeof(_vhdr), &_vhdr);
 		if (!vhdr)
@@ -1382,7 +1382,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			return err;
 	}
 
-	if (protocol == __constant_htons(ETH_P_IP)) {
+	if (protocol == htons(ETH_P_IP)) {
 		iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
 		tcph = skb->encapsulation ? inner_tcp_hdr(skb) : tcp_hdr(skb);
 		iph->tot_len = 0;
@@ -1805,9 +1805,9 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	first = &tx_ring->tx_bi[tx_ring->next_to_use];
 
 	/* setup IPv4/IPv6 offloads */
-	if (protocol == __constant_htons(ETH_P_IP))
+	if (protocol == htons(ETH_P_IP))
 		tx_flags |= I40E_TX_FLAGS_IPV4;
-	else if (protocol == __constant_htons(ETH_P_IPV6))
+	else if (protocol == htons(ETH_P_IPV6))
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
 	tso = i40e_tso(tx_ring, skb, tx_flags, protocol, &hdr_len,
-- 
1.8.3.1
