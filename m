From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 13/17] myri10ge: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:30:34 +0100
Message-ID: <1285612234.2263.313.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:52085 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933295Ab0I0Sah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:30:37 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/myri10ge/myri10ge.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 4f3a3c0..3ad1a21 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -990,7 +990,7 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		 * RX queues, so if we get an error, first retry using a
 		 * single TX queue before giving up */
 		if (status != 0 && mgp->dev->real_num_tx_queues > 1) {
-			mgp->dev->real_num_tx_queues = 1;
+			netif_set_real_num_tx_queues(mgp->dev, 1);
 			cmd.data0 = mgp->num_slices;
 			cmd.data1 = MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE;
 			status = myri10ge_send_cmd(mgp,
@@ -3923,7 +3923,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "failed to alloc slice state\n");
 		goto abort_with_firmware;
 	}
-	netdev->real_num_tx_queues = mgp->num_slices;
+	netif_set_real_num_tx_queues(netdev, mgp->num_slices);
+	netif_set_real_num_rx_queues(netdev, mgp->num_slices);
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed reset\n");
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

