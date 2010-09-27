From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 07/17] cxgb4vf: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:26:10 +0100
Message-ID: <1285611970.2263.299.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Casey Leedom <leedom@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51326 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab0I0S0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:26:13 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 7b6d07f..555ecc5 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -748,7 +748,10 @@ static int cxgb4vf_open(struct net_device *dev)
 	/*
 	 * Note that this interface is up and start everything up ...
 	 */
-	dev->real_num_tx_queues = pi->nqsets;
+	netif_set_real_num_tx_queues(dev, pi->nqsets);
+	err = netif_set_real_num_rx_queues(dev, pi->nqsets);
+	if (err)
+		return err;
 	set_bit(pi->port_id, &adapter->open_device_map);
 	link_start(dev);
 	netif_tx_start_all_queues(dev);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

