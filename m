From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: avoid division by zero
Date: Wed, 17 Aug 2016 16:00:10 +0100
Message-ID: <c09b487a-af9d-be97-c32d-dd06323bc0c8@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bert Kenward <bkenward@solarflare.com>
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:26551 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752145AbcHQPAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 11:00:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The division is already being done properly in efx_ef10_get_timer_config
which returns zero-on-success, unlike the old efx_ef10_get_sysclk_freq.

Fixes: d95e329a55ba ("sfc: get timer configuration from adapter")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index b8c9f18..2a70b1a 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -646,7 +646,6 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	rc = efx_ef10_get_timer_config(efx);
 	if (rc < 0)
 		goto fail5;
-	efx->timer_quantum_ns = 1536000 / rc; /* 1536 cycles */
 
 	rc = efx_mcdi_mon_probe(efx);
 	if (rc && rc != -EPERM)
