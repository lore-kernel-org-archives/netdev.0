From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/18] i40e/i40evf: Fix casting in transmit code
Date: Tue,  5 Apr 2016 13:17:23 -0700
Message-ID: <1459887455-146634-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759965AbcDEURj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:39 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Simple cast to fix a sparse warning.

Fixes: commit 5453205cd097 ("i40e/i40evf: Enable support for
SKB_GSO_UDP_TUNNEL_CSUM")

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 5 +++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 01cff07..5bef5b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2305,7 +2305,8 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 			/* remove payload length from outer checksum */
 			paylen = (__force u16)l4.udp->check;
-			paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+			paylen += ntohs((__force __be16)1) *
+					(u16)~(skb->len - l4_offset);
 			l4.udp->check = ~csum_fold((__force __wsum)paylen);
 		}
 
@@ -2327,7 +2328,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	/* remove payload length from inner checksum */
 	paylen = (__force u16)l4.tcp->check;
-	paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+	paylen += ntohs((__force __be16)1) * (u16)~(skb->len - l4_offset);
 	l4.tcp->check = ~csum_fold((__force __wsum)paylen);
 
 	/* compute length of segmentation header */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 9e91136..570348d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1572,7 +1572,8 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 			/* remove payload length from outer checksum */
 			paylen = (__force u16)l4.udp->check;
-			paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+			paylen += ntohs((__force __be16)1) *
+					(u16)~(skb->len - l4_offset);
 			l4.udp->check = ~csum_fold((__force __wsum)paylen);
 		}
 
@@ -1594,7 +1595,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	/* remove payload length from inner checksum */
 	paylen = (__force u16)l4.tcp->check;
-	paylen += ntohs(1) * (u16)~(skb->len - l4_offset);
+	paylen += ntohs((__force __be16)1) * (u16)~(skb->len - l4_offset);
 	l4.tcp->check = ~csum_fold((__force __wsum)paylen);
 
 	/* compute length of segmentation header */
-- 
2.5.5
