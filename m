From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/32] sfc: Limit some hardware workarounds to Falcon
Date: Sat, 28 Nov 2009 03:45:14 +0000
Message-ID: <1259379914.2811.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42417 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbZK1DpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:45:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c     |    2 +-
 drivers/net/sfc/workarounds.h |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index bb9abf2..6515b8a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -683,7 +683,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	 * and fix it be cycling transmit flow control on this end. */
 	reset = (wanted_fc & EFX_FC_TX) && !(efx->wanted_fc & EFX_FC_TX);
 	if (EFX_WORKAROUND_11482(efx) && reset) {
-		if (falcon_rev(efx) >= FALCON_REV_B0) {
+		if (falcon_rev(efx) == FALCON_REV_B0) {
 			/* Recover by resetting the EM block */
 			if (efx->link_state.up)
 				falcon_drain_tx_fifo(efx);
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 3250299..84e579e 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -17,6 +17,7 @@
 
 #define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
+#define EFX_WORKAROUND_FALCON_AB(efx) (falcon_rev(efx) <= FALCON_REV_B0)
 #define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
 #define EFX_WORKAROUND_SFT9001(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A || \
 				     (efx)->phy_type == PHY_TYPE_SFT9001B)
@@ -33,11 +34,11 @@
  * or a PCIe error (bug 11028) */
 #define EFX_WORKAROUND_10727 EFX_WORKAROUND_ALWAYS
 /* Transmit flow control may get disabled */
-#define EFX_WORKAROUND_11482 EFX_WORKAROUND_ALWAYS
+#define EFX_WORKAROUND_11482 EFX_WORKAROUND_FALCON_AB
 /* Flush events can take a very long time to appear */
 #define EFX_WORKAROUND_11557 EFX_WORKAROUND_ALWAYS
 /* Truncated IPv4 packets can confuse the TX packet parser */
-#define EFX_WORKAROUND_15592 EFX_WORKAROUND_ALWAYS
+#define EFX_WORKAROUND_15592 EFX_WORKAROUND_FALCON_AB
 
 /* Spurious parity errors in TSORT buffers */
 #define EFX_WORKAROUND_5129 EFX_WORKAROUND_FALCON_A

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

