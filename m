From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igbvf: fix issue w/ mapped_as_page being left set
	after unmap
Date: Wed, 27 Jan 2010 17:30:39 -0800
Message-ID: <20100128013012.18801.97398.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:51972
	"EHLO qmta12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752291Ab0A1BbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 20:31:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes an issue in igbvf with mapped_as_page being left set
after a page is unmapped which results in buffers which are mapped via map
single being unmapped as page.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/netdev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 297a5dd..2aa71a7 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2117,6 +2117,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
+	buffer_info->mapped_as_page = false;
 	buffer_info->dma = pci_map_single(pdev, skb->data, len,
 					  PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(pdev, buffer_info->dma))

