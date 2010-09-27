From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 08/17] gianfar: Use
 netif_set_real_num_rx_queues()
Date: Mon, 27 Sep 2010 19:27:37 +0100
Message-ID: <1285612057.2263.302.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Anton Vorontsov <avorontsov@mvista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51515 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759938Ab0I0S1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:27:40 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not set num_tx_queues or real_num_tx_queues, since
alloc_etherdev_mq() does that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/gianfar.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f30adbf..6180089 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -654,9 +654,8 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	priv->node = ofdev->dev.of_node;
 	priv->ndev = dev;
 
-	dev->num_tx_queues = num_tx_qs;
-	dev->real_num_tx_queues = num_tx_qs;
 	priv->num_tx_queues = num_tx_qs;
+	netif_set_real_num_rx_queues(dev, num_rx_qs);
 	priv->num_rx_queues = num_rx_qs;
 	priv->num_grps = 0x0;
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

