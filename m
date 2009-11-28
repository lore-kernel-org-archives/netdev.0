From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/12] sfc: Remove EFX_WORKAROUND_9141 macro
Date: Sat, 28 Nov 2009 15:35:24 +0000
Message-ID: <1259422524.3709.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59130 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbZK1PfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:35:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

The "bug9141 workaround" of setting TX_FLUSH_MIN_LEN_EN should really
be considered as a normal bit of configuration rather than a
workaround.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |    2 +-
 drivers/net/sfc/workarounds.h |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9c4f898..b186fd2 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3128,7 +3128,7 @@ int falcon_init_nic(struct efx_nic *efx)
 	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
 	/* Squash TX of packets of 16 bytes or less */
-	if (falcon_rev(efx) >= FALCON_REV_B0 && EFX_WORKAROUND_9141(efx))
+	if (falcon_rev(efx) >= FALCON_REV_B0)
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
 	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
 
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 84e579e..bad0932 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -28,8 +28,6 @@
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* Bit-bashed I2C reads cause performance drop */
 #define EFX_WORKAROUND_7884 EFX_WORKAROUND_10G
-/* TX pkt parser problem with <= 16 byte TXes */
-#define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
 /* TX_EV_PKT_ERR can be caused by a dangling TX descriptor
  * or a PCIe error (bug 11028) */
 #define EFX_WORKAROUND_10727 EFX_WORKAROUND_ALWAYS
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

