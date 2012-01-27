From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/32] sfc: Use new names for MC shared memory
 layout constants
Date: Fri, 27 Jan 2012 20:45:22 +0000
Message-ID: <1327697122.2503.18.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63595 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754066Ab2A0Up0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:45:26 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are defined alongside the firmware protocol in mcdi_pcol.h.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index f16145d..e5837a6 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -22,18 +22,12 @@
  **************************************************************************
  */
 
-/* Software-defined structure to the shared-memory */
-#define CMD_NOTIFY_PORT0 0
-#define CMD_NOTIFY_PORT1 4
-#define CMD_PDU_PORT0    0x008
-#define CMD_PDU_PORT1    0x108
-
 #define MCDI_RPC_TIMEOUT       10 /*seconds */
 
 #define MCDI_PDU(efx)							\
-	(efx_port_num(efx) ? CMD_PDU_PORT1 : CMD_PDU_PORT0)
+	(efx_port_num(efx) ? MC_SMEM_P1_PDU_OFST : MC_SMEM_P0_PDU_OFST)
 #define MCDI_DOORBELL(efx)						\
-	(efx_port_num(efx) ? CMD_NOTIFY_PORT1 : CMD_NOTIFY_PORT0)
+	(efx_port_num(efx) ? MC_SMEM_P1_DOORBELL_OFST : MC_SMEM_P0_DOORBELL_OFST)
 #define MCDI_STATUS(efx)						\
 	(efx_port_num(efx) ? MC_SMEM_P1_STATUS_OFST : MC_SMEM_P0_STATUS_OFST)
 
@@ -83,7 +77,7 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 	u32 xflags, seqno;
 
 	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
-	BUG_ON(inlen & 3 || inlen >= 0x100);
+	BUG_ON(inlen & 3 || inlen >= MC_SMEM_PDU_LEN);
 
 	seqno = mcdi->seqno & SEQ_MASK;
 	xflags = 0;
@@ -117,7 +111,7 @@ static void efx_mcdi_copyout(struct efx_nic *efx, u8 *outbuf, size_t outlen)
 	int i;
 
 	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
-	BUG_ON(outlen & 3 || outlen >= 0x100);
+	BUG_ON(outlen & 3 || outlen >= MC_SMEM_PDU_LEN);
 
 	for (i = 0; i < outlen; i += 4)
 		*((__le32 *)(outbuf + i)) = _efx_readd(efx, pdu + 4 + i);
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
