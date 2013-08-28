From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/16] sfc: PTP MCDI requests need to initialise
 periph ID field
Date: Wed, 28 Aug 2013 16:18:42 +0100
Message-ID: <1377703122.2264.28.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17200 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381Ab3H1PSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:18:46 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurence Evans <levans@solarflare.com>

This field is ignored by Siena firmware but is significant to EF10 firmware.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index b386901..4de2f8f 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -313,6 +313,7 @@ static int efx_ptp_enable(struct efx_nic *efx)
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ENABLE_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ENABLE);
+	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ENABLE_QUEUE,
 		       efx->ptp_data->channel->channel);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ENABLE_MODE, efx->ptp_data->mode);
@@ -331,6 +332,7 @@ static int efx_ptp_disable(struct efx_nic *efx)
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_DISABLE_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_DISABLE);
+	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 	return efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
 			    NULL, 0, NULL);
 }
@@ -531,6 +533,7 @@ static int efx_ptp_synchronize(struct efx_nic *efx, unsigned int num_readings)
 	int *start = ptp->start.addr;
 
 	MCDI_SET_DWORD(synch_buf, PTP_IN_OP, MC_CMD_PTP_OP_SYNCHRONIZE);
+	MCDI_SET_DWORD(synch_buf, PTP_IN_PERIPH_ID, 0);
 	MCDI_SET_DWORD(synch_buf, PTP_IN_SYNCHRONIZE_NUMTIMESETS,
 		       num_readings);
 	MCDI_SET_QWORD(synch_buf, PTP_IN_SYNCHRONIZE_START_ADDR,
@@ -574,6 +577,7 @@ static int efx_ptp_xmit_skb(struct efx_nic *efx, struct sk_buff *skb)
 	size_t len;
 
 	MCDI_SET_DWORD(ptp_data->txbuf, PTP_IN_OP, MC_CMD_PTP_OP_TRANSMIT);
+	MCDI_SET_DWORD(ptp_data->txbuf, PTP_IN_PERIPH_ID, 0);
 	MCDI_SET_DWORD(ptp_data->txbuf, PTP_IN_TRANSMIT_LENGTH, skb->len);
 	if (skb_shinfo(skb)->nr_frags != 0) {
 		rc = skb_linearize(skb);
@@ -1377,6 +1381,7 @@ static int efx_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 			 (PPB_EXTRA_BITS + MAX_PPB_BITS));
 
 	MCDI_SET_DWORD(inadj, PTP_IN_OP, MC_CMD_PTP_OP_ADJUST);
+	MCDI_SET_DWORD(inadj, PTP_IN_PERIPH_ID, 0);
 	MCDI_SET_QWORD(inadj, PTP_IN_ADJUST_FREQ, adjustment_ns);
 	MCDI_SET_DWORD(inadj, PTP_IN_ADJUST_SECONDS, 0);
 	MCDI_SET_DWORD(inadj, PTP_IN_ADJUST_NANOSECONDS, 0);
@@ -1399,6 +1404,7 @@ static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ADJUST_LEN);
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ADJUST);
+	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 	MCDI_SET_QWORD(inbuf, PTP_IN_ADJUST_FREQ, 0);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_SECONDS, (u32)delta_ts.tv_sec);
 	MCDI_SET_DWORD(inbuf, PTP_IN_ADJUST_NANOSECONDS, (u32)delta_ts.tv_nsec);
@@ -1417,6 +1423,7 @@ static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_READ_NIC_TIME);
+	MCDI_SET_DWORD(inbuf, PTP_IN_PERIPH_ID, 0);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_PTP, inbuf, sizeof(inbuf),
 			  outbuf, sizeof(outbuf), NULL);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
