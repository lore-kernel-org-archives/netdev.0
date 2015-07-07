From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 3/3] sfc: suppress handled MCDI failures when changing
 the MAC address
Date: Tue, 7 Jul 2015 11:37:33 +0100
Message-ID: <559BABED.4010300@solarflare.com>
References: <559BAB66.1080905@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:43372 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755475AbbGGKhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:37:39 -0400
In-Reply-To: <559BAB66.1080905@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index e0cb361..605cc89 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3933,8 +3933,8 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 			efx->net_dev->dev_addr);
 	MCDI_SET_DWORD(inbuf, VADAPTOR_SET_MAC_IN_UPSTREAM_PORT_ID,
 		       nic_data->vport_id);
-	rc = efx_mcdi_rpc(efx, MC_CMD_VADAPTOR_SET_MAC, inbuf,
-			  sizeof(inbuf), NULL, 0, NULL);
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_VADAPTOR_SET_MAC, inbuf,
+				sizeof(inbuf), NULL, 0, NULL);
 
 	efx_ef10_filter_table_probe(efx);
 	up_write(&efx->filter_sem);
@@ -3986,6 +3986,9 @@ static int efx_ef10_set_mac_address(struct efx_nic *efx)
 		 * MCFW do not support VFs.
 		 */
 		rc = efx_ef10_vport_set_mac_address(efx);
+	} else {
+		efx_mcdi_display_error(efx, MC_CMD_VADAPTOR_SET_MAC,
+				       sizeof(inbuf), NULL, 0, rc);
 	}
 
 	return rc;
