From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 6/7] sfc: Improve reliability of RX queue flushing
Date: Wed, 26 Aug 2009 19:18:13 +0100
Message-ID: <1251310693.27345.19.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:45661 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752672AbZHZSSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:18:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reconfiguring the port requires us to flush all DMA queues.  In
repeated testing we have found that RX flushes would sometimes fail
because the RX DMA engine was not properly isolated from the MACs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d4dc920..07a7e4b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1179,6 +1179,8 @@ static void efx_stop_all(struct efx_nic *efx)
 
 	/* Isolate the MAC from the TX and RX engines, so that queue
 	 * flushes will complete in a timely fashion. */
+	falcon_deconfigure_mac_wrapper(efx);
+	msleep(10); /* Let the Rx FIFO drain */
 	falcon_drain_tx_fifo(efx);
 
 	/* Stop the kernel transmit interface late, so the watchdog

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

