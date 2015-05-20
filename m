From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 03/16] sfc: MC_CMD_SET_MAC can only be called
 by the link control Function
Date: Wed, 20 May 2015 11:08:56 +0100
Message-ID: <555C5D38.5030907@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:16590 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752950AbbETKJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:09:03 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MC_CMD_SET_MAC is privileged and can only by called by the link
control function.

This patch adds efx_ef10_mac_reconfigure_vf which avoids the call
to MC_CMD_SET_MAC by the Virtual function

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 882117a..70cbad3 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3480,6 +3480,13 @@ static int efx_ef10_mac_reconfigure(struct efx_nic *efx)
 	return efx_mcdi_set_mac(efx);
 }
 
+static int efx_ef10_mac_reconfigure_vf(struct efx_nic *efx)
+{
+	efx_ef10_filter_sync_rx_mode(efx);
+
+	return 0;
+}
+
 static int efx_ef10_start_bist(struct efx_nic *efx, u32 bist_type)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_START_BIST_IN_LEN);
@@ -3833,7 +3840,7 @@ const struct efx_nic_type efx_hunt_a0_vf_nic_type = {
 	.stop_stats = efx_port_dummy_op_void,
 	.set_id_led = efx_mcdi_set_id_led,
 	.push_irq_moderation = efx_ef10_push_irq_moderation,
-	.reconfigure_mac = efx_ef10_mac_reconfigure,
+	.reconfigure_mac = efx_ef10_mac_reconfigure_vf,
 	.check_mac_fault = efx_mcdi_mac_check_fault,
 	.reconfigure_port = efx_mcdi_port_reconfigure,
 	.get_wol = efx_ef10_get_wol_vf,
