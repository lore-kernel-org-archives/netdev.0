From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 05/14] sfc: set the port-id when calling MC_CMD_MAC_STATS
Date: Fri, 29 May 2015 11:01:56 +0100
Message-ID: <55683914.9080303@solarflare.com>
References: <55683895.2090408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:27290 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755397AbbE2KCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:02:03 -0400
In-Reply-To: <55683895.2090408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The port-id must be known so that the RMON level can be
set for the collection of vadapter stats.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_port.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 9bf04cb..fffc348 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -924,6 +924,7 @@ enum efx_stats_action {
 static int efx_mcdi_mac_stats(struct efx_nic *efx,
 			      enum efx_stats_action action, int clear)
 {
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
 	int rc;
 	int change = action == EFX_STATS_PULL ? 0 : 1;
@@ -945,6 +946,7 @@ static int efx_mcdi_mac_stats(struct efx_nic *efx,
 			      MAC_STATS_IN_PERIODIC_NOEVENT, 1,
 			      MAC_STATS_IN_PERIOD_MS, period);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
+	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_PORT_ID, nic_data->vport_id);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),
 			  NULL, 0, NULL);
