From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 02/10] sfc: Use ACCESS_ONCE when copying
 efx_tx_queue::read_count
Date: Fri, 10 Dec 2010 17:38:17 +0000
Message-ID: <1292002697.11673.16.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26836 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420Ab0LJRiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:38:20 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 03194f7..fef2235 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -240,8 +240,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 				 * of read_count. */
 				smp_mb();
 				tx_queue->old_read_count =
-					*(volatile unsigned *)
-					&tx_queue->read_count;
+					ACCESS_ONCE(tx_queue->read_count);
 				fill_level = (tx_queue->insert_count
 					      - tx_queue->old_read_count);
 				q_space = efx->txq_entries - 1 - fill_level;
@@ -764,7 +763,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			 * stopped from the access of read_count. */
 			smp_mb();
 			tx_queue->old_read_count =
-				*(volatile unsigned *)&tx_queue->read_count;
+				ACCESS_ONCE(tx_queue->read_count);
 			fill_level = (tx_queue->insert_count
 				      - tx_queue->old_read_count);
 			q_space = efx->txq_entries - 1 - fill_level;
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

