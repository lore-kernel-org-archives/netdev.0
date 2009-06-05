From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 01/10] ixgbe: use rx_buffer_info->dma instead of
	nr_frags to determine skb unmap
Date: Thu, 04 Jun 2009 18:59:49 -0700
Message-ID: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:52817 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbZFECAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:00:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the driver so that it uses rx_buffer_info->dma to
determine if it needs to unmap the page instead of sh_info->nr_frags.  This
helps to prevent a cache line miss when receiving small packets as the
rx_buffer_info data should already be in the cache.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9684632..e1efa1d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -708,7 +708,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		prefetch(skb->data - NET_IP_ALIGN);
 		rx_buffer_info->skb = NULL;
 
-		if (len && !skb_shinfo(skb)->nr_frags) {
+		if (rx_buffer_info->dma) {
 			pci_unmap_single(pdev, rx_buffer_info->dma,
 			                 rx_ring->rx_buf_len,
 			                 PCI_DMA_FROMDEVICE);

