From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 8/8] sfc: Disable TX descriptor prefetch watchdog
Date: Wed, 23 Dec 2009 23:49:13 +0000
Message-ID: <1261612153.2782.102.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28337 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757557AbZLWXtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:49:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This hardware watchdog can misfire, so it does more harm than good.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index a577be2..db44224 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -1576,6 +1576,8 @@ void efx_nic_init_common(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_SOFT_EVT_EN, 1);
 	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
 	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
+	/* Disable hardware watchdog which can misfire */
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_WD_TMR, 0x3fffff);
 	/* Squash TX of packets of 16 bytes or less */
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

