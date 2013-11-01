From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbevf: remove redundant workaround
Date: Fri,  1 Nov 2013 06:56:46 -0700
Message-ID: <1383314210-24289-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12204 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753488Ab3KAN4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:54 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch removes a workaround related to header split, which is redundant
because the driver does not support splitting packet headers on Rx.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b16b694..9685354 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -497,15 +497,6 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		/*
-		 * Work around issue of some types of VM to VM loop back
-		 * packets not getting split correctly
-		 */
-		if (staterr & IXGBE_RXD_STAT_LB) {
-			u32 header_fixup_len = skb_headlen(skb);
-			if (header_fixup_len < 14)
-				skb_push(skb, header_fixup_len);
-		}
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 
 		/* Workaround hardware that can't do proper VEPA multicast
-- 
1.8.3.1
