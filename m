From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 09/17] igb: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:28:39 +0100
Message-ID: <1285612119.2263.305.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51798 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759938Ab0I0S2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:28:44 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/igb/igb_main.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0394ca9..55edcb7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -988,7 +988,7 @@ static void igb_clear_interrupt_scheme(struct igb_adapter *adapter)
  * Attempt to configure interrupts using the best available
  * capabilities of the hardware and kernel.
  **/
-static void igb_set_interrupt_capability(struct igb_adapter *adapter)
+static int igb_set_interrupt_capability(struct igb_adapter *adapter)
 {
 	int err;
 	int numvecs, i;
@@ -1054,8 +1054,10 @@ msi_only:
 	if (!pci_enable_msi(adapter->pdev))
 		adapter->flags |= IGB_FLAG_HAS_MSI;
 out:
-	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
+	/* Notify the stack of the (possibly) reduced queue counts. */
+	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
+	return netif_set_real_num_rx_queues(adapter->netdev,
+					    adapter->num_rx_queues);
 }
 
 /**
@@ -1154,7 +1156,9 @@ static int igb_init_interrupt_scheme(struct igb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int err;
 
-	igb_set_interrupt_capability(adapter);
+	err = igb_set_interrupt_capability(adapter);
+	if (err)
+		return err;
 
 	err = igb_alloc_q_vectors(adapter);
 	if (err) {
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

