From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 16/17] tg3: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:32:37 +0100
Message-ID: <1285612357.2263.319.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52339 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757166Ab0I0Sck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:32:40 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This *always* sets real_num_tx_queues to 1, so this could be improved.
For now, do a simple conversion.

Ben.

 drivers/net/tg3.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fdb438d..ca41140 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8821,7 +8821,11 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
 
-	tp->dev->real_num_tx_queues = 1;
+	netif_set_real_num_tx_queues(tp->dev, 1);
+	if (netif_set_real_num_rx_queues(tp->dev, tp->irq_cnt)) {
+		pci_disable_msix(tp->pdev);
+		return false;
+	}
 	if (tp->irq_cnt > 1)
 		tp->tg3_flags3 |= TG3_FLG3_ENABLE_RSS;
 
@@ -8856,7 +8860,7 @@ defcfg:
 	if (!(tp->tg3_flags2 & TG3_FLG2_USING_MSIX)) {
 		tp->irq_cnt = 1;
 		tp->napi[0].irq_vec = tp->pdev->irq;
-		tp->dev->real_num_tx_queues = 1;
+		netif_set_real_num_tx_queues(tp->dev, 1);
 	}
 }
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

