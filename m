From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] igb: Drop BUILD_BUG_ON check from igb_build_rx_buffer
Date: Tue,  5 Mar 2013 01:48:35 -0800
Message-ID: <1362476917-5189-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40681 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540Ab3CEJsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 04:48:42 -0500
In-Reply-To: <1362476917-5189-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

On s390 the igb driver was throwing a build error due to the fact that a frame
built using build_skb would be larger than 2K.  Since this is not likely to
change at any point in the future we are better off just dropping the check
since we already had a check in igb_set_rx_buffer_len that will just disable
the usage of build_skb anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ed79a1c..4d53a17 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6227,13 +6227,6 @@ static struct sk_buff *igb_build_rx_buffer(struct igb_ring *rx_ring,
 	/* If we spanned a buffer we have a huge mess so test for it */
 	BUG_ON(unlikely(!igb_test_staterr(rx_desc, E1000_RXD_STAT_EOP)));
 
-	/* Guarantee this function can be used by verifying buffer sizes */
-	BUILD_BUG_ON(SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD +
-							NET_IP_ALIGN +
-							IGB_TS_HDR_LEN +
-							ETH_FRAME_LEN +
-							ETH_FCS_LEN));
-
 	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
 	page = rx_buffer->page;
 	prefetchw(page);
-- 
1.7.11.7
