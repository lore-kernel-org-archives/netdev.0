From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] ixgbe: Drop Rx alloc at end of Rx cleanup
Date: Fri, 12 Sep 2014 05:33:43 -0700
Message-ID: <1410525231-19851-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39378 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967AbaILMd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 08:33:57 -0400
In-Reply-To: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes the Rx buffer allocation at the end of ixgbe_clean_rx_irq.
The reason for removing this is to avoid the extra latency introduced by the
MMIO write.  This can amount to somewhere around an extra 100ns of latency and
one extra message worth of PCIe bus overhead.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 87613806..6a12bb1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2077,9 +2077,6 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	q_vector->rx.total_packets += total_rx_packets;
 	q_vector->rx.total_bytes += total_rx_bytes;
 
-	if (cleaned_count)
-		ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
-
 	return total_rx_packets;
 }
 
-- 
1.9.3
