From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/17] sfc: Test only the first pair of TX queues
Date: Wed, 28 Apr 2010 20:30:30 +0100
Message-ID: <1272483030.2549.32.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12638 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839Ab0D1Tad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:30:33 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes no immediate difference, but we definitely do not want
to test all TX queues once we allocate a pair of TX queues to each
channel.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c  |    2 +-
 drivers/net/sfc/selftest.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index d9f9c02..cbe9319 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -304,7 +304,7 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
 {
 	struct efx_tx_queue *tx_queue;
 
-	efx_for_each_tx_queue(tx_queue, efx) {
+	efx_for_each_channel_tx_queue(tx_queue, &efx->channel[0]) {
 		efx_fill_test(test_index++, strings, data,
 			      &lb_tests->tx_sent[tx_queue->queue],
 			      EFX_TX_QUEUE_NAME(tx_queue),
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 0106b1d..3a16e06 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -616,8 +616,8 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 			goto out;
 		}
 
-		/* Test every TX queue */
-		efx_for_each_tx_queue(tx_queue, efx) {
+		/* Test both types of TX queue */
+		efx_for_each_channel_tx_queue(tx_queue, &efx->channel[0]) {
 			state->offload_csum = (tx_queue->queue ==
 					       EFX_TX_QUEUE_OFFLOAD_CSUM);
 			rc = efx_test_loopback(tx_queue,
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

