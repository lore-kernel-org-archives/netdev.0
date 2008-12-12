From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 25/33] sfc: Generate unique names for per-NIC workqueues
Date: Fri, 12 Dec 2008 12:56:57 +0000
Message-ID: <20081212125656.GY10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:57528 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757873AbYLLM47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:56:59 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ce1c7d3..c094845 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1854,6 +1854,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	char name[16];
 	int i;
 
 	/* Initialise common structures */
@@ -1924,7 +1925,9 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
 				  interrupt_mode);
 
-	efx->workqueue = create_singlethread_workqueue("sfc_work");
+	/* Would be good to use the net_dev name, but we're too early */
+	snprintf(name, sizeof(name), "sfc%s", pci_name(pci_dev));
+	efx->workqueue = create_singlethread_workqueue(name);
 	if (!efx->workqueue)
 		return -ENOMEM;
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
