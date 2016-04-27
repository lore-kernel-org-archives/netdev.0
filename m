From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/14] i40e/i40evf: Only offload VLAN tag if enabled
Date: Wed, 27 Apr 2016 13:15:50 -0700
Message-ID: <1461788153-12869-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44403 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbcD0UQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 16:16:31 -0400
In-Reply-To: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was offloading the VLAN tag into the skb
any time there was a VLAN tag and the hardware stripping was
enabled.  Just check to make sure it's enabled before put_tag.

Change-Id: Ife95290c06edd9a616393b38679923938b382241
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6e44cf1..285efe9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1370,7 +1370,8 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
 {
 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
 
-	if (vlan_tag & VLAN_VID_MASK)
+	if ((rx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+	    (vlan_tag & VLAN_VID_MASK))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
 	napi_gro_receive(&q_vector->napi, skb);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index f101895..4633235 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -842,7 +842,8 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
 {
 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
 
-	if (vlan_tag & VLAN_VID_MASK)
+	if ((rx_ring->netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+	    (vlan_tag & VLAN_VID_MASK))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
 	napi_gro_receive(&q_vector->napi, skb);
-- 
2.5.5
