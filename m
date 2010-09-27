From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 06/17] cxgb4: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:25:57 +0100
Message-ID: <1285611957.2263.298.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Dimitris Michailidis <dm@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51248 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab0I0S0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:26:01 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 75b9401..4fb08e3 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2763,7 +2763,10 @@ static int cxgb_open(struct net_device *dev)
 			return err;
 	}
 
-	dev->real_num_tx_queues = pi->nqsets;
+	netif_set_real_num_tx_queues(dev, pi->nqsets);
+	err = netif_set_real_num_rx_queues(dev, pi->nqsets);
+	if (err)
+		return err;
 	err = link_start(dev);
 	if (!err)
 		netif_tx_start_all_queues(dev);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

