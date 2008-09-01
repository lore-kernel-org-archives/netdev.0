From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/52] sfc: Don't leak PCI DMA maps in the TSO code when the queue fills up
Date: Mon, 1 Sep 2008 12:46:36 +0100
Message-ID: <20080901114636.GH7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34214 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756521AbYIALqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:39 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index e5e0bab..0452ea6 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -1096,6 +1096,11 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 		efx_stop_queue(tx_queue->efx);
 
  unwind:
+	/* Free the DMA mapping we were in the process of writing out */
+	if (state.ifc.unmap_len)
+		pci_unmap_page(tx_queue->efx->pci_dev, state.ifc.unmap_addr,
+			       state.ifc.unmap_len, PCI_DMA_TODEVICE);
+
 	efx_enqueue_unwind(tx_queue);
 	return rc2;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

