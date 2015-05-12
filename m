From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: nicer log message on PTP probe fail
Date: Tue, 12 May 2015 13:04:52 +0100
Message-ID: <5551EC64.7040307@solarflare.com>
References: <5551EC0F.2080607@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:27313 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932385AbbELMFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:05:04 -0400
In-Reply-To: <5551EC0F.2080607@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index a2e9aee..8c5c96a 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -604,7 +604,12 @@ static int efx_ptp_disable(struct efx_nic *efx)
 	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
 				outbuf, sizeof(outbuf), NULL);
 	rc = (rc == -EALREADY) ? 0 : rc;
-	if (rc)
+	/* If we get ENOSYS, the NIC doesn't support PTP, and thus this function
+	 * should only have been called during probe.
+	 */
+	if (rc == -ENOSYS || rc == -EPERM)
+		netif_info(efx, probe, efx->net_dev, "no PTP support\n");
+	else if (rc)
 		efx_mcdi_display_error(efx, MC_CMD_PTP,
 				       MC_CMD_PTP_IN_DISABLE_LEN,
 				       outbuf, sizeof(outbuf), rc);
