From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 05/17] cxgb3: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:25:44 +0100
Message-ID: <1285611944.2263.297.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Divy Le Ray <divy@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51222 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab0I0SZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:25:47 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/cxgb3/cxgb3_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index f9eede0..a04ce6a 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1399,7 +1399,10 @@ static int cxgb_open(struct net_device *dev)
 			       "Could not initialize offload capabilities\n");
 	}
 
-	dev->real_num_tx_queues = pi->nqsets;
+	netif_set_real_num_tx_queues(dev, pi->nqsets);
+	err = netif_set_real_num_rx_queues(dev, pi->nqsets);
+	if (err)
+		return err;
 	link_start(dev);
 	t3_port_intr_enable(adapter, pi->port_id);
 	netif_tx_start_all_queues(dev);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

