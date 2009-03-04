From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/7] sfc: Don't wake TX queues while they're being flushed
Date: Wed, 04 Mar 2009 19:53:15 +0000
Message-ID: <1236196395.3140.23.camel@achroite>
References: <1236196272.3140.15.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:57619 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756267AbZCDTxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 14:53:17 -0500
In-Reply-To: <1236196272.3140.15.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 9f97e44..b1e1907 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -400,7 +400,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	 * separates the update of read_count from the test of
 	 * stopped. */
 	smp_mb();
-	if (unlikely(tx_queue->stopped)) {
+	if (unlikely(tx_queue->stopped) && likely(efx->port_enabled)) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
 		if (fill_level < EFX_NETDEV_TX_THRESHOLD(tx_queue)) {
 			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

