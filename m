From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] ixgbe: remove rx_hdr_split debug counter for
	non-debug configurations
Date: Tue, 26 May 2009 17:54:45 -0700
Message-ID: <20090527005445.28535.9069.stgit@localhost.localdomain>
References: <20090527005403.28535.8727.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:47014
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754690AbZE0AzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 20:55:00 -0400
In-Reply-To: <20090527005403.28535.8727.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The counter rx_hdr_split was meant to be a debug counter.  As such it
should only be enabled when debugging.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    2 ++
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 ++
 drivers/net/ixgbe/ixgbe_main.c    |    2 ++
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 0f396d2..f3f67d9 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -284,7 +284,9 @@ struct ixgbe_adapter {
 	struct ixgbe_ring_feature ring_feature[RING_F_ARRAY_SIZE];
 	struct msix_entry *msix_entries;
 
+#ifdef DEBUG
 	u64 rx_hdr_split;
+#endif
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 35255b8..f097014 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -87,7 +87,9 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_csum_offload_good", IXGBE_STAT(hw_csum_rx_good)},
 	{"rx_csum_offload_errors", IXGBE_STAT(hw_csum_rx_error)},
 	{"tx_csum_offload_ctxt", IXGBE_STAT(hw_csum_tx_good)},
+#ifdef DEBUG
 	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
+#endif
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
 	{"rx_no_dma_resources", IXGBE_STAT(hw_rx_no_dma_resources)},
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 373cdc7..496bffb 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -694,8 +694,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
 			       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
+#ifdef DEBUG
 			if (hdr_info & IXGBE_RXDADV_SPH)
 				adapter->rx_hdr_split++;
+#endif
 			if (len > IXGBE_RX_HDR_SIZE)
 				len = IXGBE_RX_HDR_SIZE;
 			upper_len = le16_to_cpu(rx_desc->wb.upper.length);

