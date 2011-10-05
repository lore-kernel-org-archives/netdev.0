From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 4/8] et131x: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 11:28:48 +0100
Message-ID: <1317810532-24984-4-git-send-email-ian.campbell@citrix.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Mark Einon <mark.einon@gmail.com>, devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27833 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934347Ab1JEK3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:29:06 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Mark Einon <mark.einon@gmail.com>
Cc: devel@driverdev.osuosl.org
Cc: netdev@vger.kernel.org
---
 drivers/staging/et131x/et1310_tx.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131x/et1310_tx.c
index 8fb3051..03e7a4e 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -519,12 +519,12 @@ static int nic_send_packet(struct et131x_adapter *etdev, struct tcb *tcb)
 			 * returned by pci_map_page() is always 32-bit
 			 * addressable (as defined by the pci/dma subsystem)
 			 */
-			desc[frag++].addr_lo =
-			    pci_map_page(etdev->pdev,
-					 frags[i - 1].page,
-					 frags[i - 1].page_offset,
-					 frags[i - 1].size,
-					 PCI_DMA_TODEVICE);
+			desc[frag++].addr_lo = skb_frag_dma_map(
+							&etdev->pdev->dev,
+							&frags[i - 1],
+							0,
+							frags[i - 1].size,
+							PCI_DMA_TODEVICE);
 		}
 	}
 
-- 
1.7.2.5
