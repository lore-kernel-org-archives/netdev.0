From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 14/17] niu: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:30:59 +0100
Message-ID: <1285612259.2263.314.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52125 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933277Ab0I0SbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:31:02 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/niu.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 4cd9242..c0437fd 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4501,7 +4501,8 @@ static int niu_alloc_channels(struct niu *np)
 	np->num_rx_rings = parent->rxchan_per_port[port];
 	np->num_tx_rings = parent->txchan_per_port[port];
 
-	np->dev->real_num_tx_queues = np->num_tx_rings;
+	netif_set_real_num_rx_queues(np->dev, np->num_rx_rings);
+	netif_set_real_num_tx_queues(np->dev, np->num_tx_rings);
 
 	np->rx_rings = kcalloc(np->num_rx_rings, sizeof(struct rx_ring_info),
 			       GFP_KERNEL);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

