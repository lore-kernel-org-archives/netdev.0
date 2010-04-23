From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 8/9] sfc: Reconfigure the XAUI serdes after an EM
 reset
Date: Fri, 23 Apr 2010 23:28:00 +0100
Message-ID: <1272061680.5520.21.camel@achroite.uk.solarflarecom.com>
References: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46386 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494Ab0DWW2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:28:03 -0400
In-Reply-To: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Fix a regression introduced in d3245b28ef2a45ec4e115062a38100bd06229289
"sfc: Refactor link configuration".

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |    3 +++
 drivers/net/sfc/falcon_xmac.c |    2 +-
 drivers/net/sfc/nic.h         |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e783b0a..655b697 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -507,6 +507,9 @@ static void falcon_reset_macs(struct efx_nic *efx)
 	/* Ensure the correct MAC is selected before statistics
 	 * are re-enabled by the caller */
 	efx_writeo(efx, &mac_ctrl, FR_AB_MAC_CTRL);
+
+	/* This can run even when the GMAC is selected */
+	falcon_setup_xaui(efx);
 }
 
 void falcon_drain_tx_fifo(struct efx_nic *efx)
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 3d65abf..c84a2ce 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -26,7 +26,7 @@
  *************************************************************************/
 
 /* Configure the XAUI driver that is an output from Falcon */
-static void falcon_setup_xaui(struct efx_nic *efx)
+void falcon_setup_xaui(struct efx_nic *efx)
 {
 	efx_oword_t sdctl, txdrv;
 
diff --git a/drivers/net/sfc/nic.h b/drivers/net/sfc/nic.h
index 3166baf..bcf1ac4 100644
--- a/drivers/net/sfc/nic.h
+++ b/drivers/net/sfc/nic.h
@@ -203,6 +203,7 @@ extern void falcon_irq_ack_a1(struct efx_nic *efx);
 extern int efx_nic_flush_queues(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
+extern void falcon_setup_xaui(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
 extern void efx_nic_init_common(struct efx_nic *efx);
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

