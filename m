From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/10] i40e/i40evf: Clean-up process_skb_fields
Date: Mon, 27 Mar 2017 16:52:06 -0700
Message-ID: <20170327235210.28652-7-jeffrey.t.kirsher@intel.com>
References: <20170327235210.28652-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46923 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753296AbdC0Xwj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 19:52:39 -0400
In-Reply-To: <20170327235210.28652-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is a minor clean-up to make the i40e/i40evf process_skb_fields
function look a little more like what we have in igb.  The Rx checksum
function called out a need for skb->protocol but I can't see where it
actually needs it.  I am assuming this is something that was likely
refactored out some time ago as the Rx checksum code has gone through a few
rewrites.

Change-ID: I0b4668a34d90b61b66ded7c7c26e19a3e2d06251
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 8 +++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 8 +++-----
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9f2c9f1b8e06..a40338fd0126 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1392,8 +1392,6 @@ bool i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
  * @vsi: the VSI we care about
  * @skb: skb currently being received and modified
  * @rx_desc: the receive descriptor
- *
- * skb->protocol must be set before this function is called
  **/
 static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    struct sk_buff *skb,
@@ -1555,12 +1553,12 @@ void i40e_process_skb_fields(struct i40e_ring *rx_ring,
 
 	i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
 
-	/* modifies the skb - consumes the enet header */
-	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
-
 	i40e_rx_checksum(rx_ring->vsi, skb, rx_desc);
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
+
+	/* modifies the skb - consumes the enet header */
+	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 38f93075f496..8915c5598d20 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -764,8 +764,6 @@ bool i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
  * @vsi: the VSI we care about
  * @skb: skb currently being received and modified
  * @rx_desc: the receive descriptor
- *
- * skb->protocol must be set before this function is called
  **/
 static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 				    struct sk_buff *skb,
@@ -917,12 +915,12 @@ void i40evf_process_skb_fields(struct i40e_ring *rx_ring,
 {
 	i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
 
-	/* modifies the skb - consumes the enet header */
-	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
-
 	i40e_rx_checksum(rx_ring->vsi, skb, rx_desc);
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
+
+	/* modifies the skb - consumes the enet header */
+	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 }
 
 /**
-- 
2.12.0
