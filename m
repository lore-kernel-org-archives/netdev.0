From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH RESEND net-next 09/16] sfc: Introduce and use
 MCDI_CTL_SDU_LEN_MAX_V1 macro for Siena-specific code
Date: Thu, 22 Aug 2013 20:27:43 +0100
Message-ID: <1377199663.1703.58.camel@bwh-desktop.uk.level5networks.com>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29838 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab3HVT1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:27:46 -0400
In-Reply-To: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MCDI version 2 protocol supports larger payloads, but will
not be implemented on Siena.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h   | 4 +++-
 drivers/net/ethernet/sfc/siena_sriov.c | 7 ++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index c5c9747..5f2846c 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -100,7 +100,9 @@
 #define MCDI_HEADER_XFLAGS_EVREQ 0x01
 
 /* Maximum number of payload bytes */
-#define MCDI_CTL_SDU_LEN_MAX 0xfc
+#define MCDI_CTL_SDU_LEN_MAX_V1 0xfc
+
+#define MCDI_CTL_SDU_LEN_MAX MCDI_CTL_SDU_LEN_MAX_V1
 
 /* The MC can generate events for two reasons:
  *   - To complete a shared memory request if XFLAGS_EVREQ was set
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 8e46fac..c376e90 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -248,11 +248,11 @@ static int efx_sriov_memcpy(struct efx_nic *efx, struct efx_memcpy_req *req,
 	mb();	/* Finish writing source/reading dest before DMA starts */
 
 	used = MC_CMD_MEMCPY_IN_LEN(count);
-	if (WARN_ON(used > MCDI_CTL_SDU_LEN_MAX))
+	if (WARN_ON(used > MCDI_CTL_SDU_LEN_MAX_V1))
 		return -ENOBUFS;
 
 	/* Allocate room for the largest request */
-	inbuf = kzalloc(MCDI_CTL_SDU_LEN_MAX, GFP_KERNEL);
+	inbuf = kzalloc(MCDI_CTL_SDU_LEN_MAX_V1, GFP_KERNEL);
 	if (inbuf == NULL)
 		return -ENOMEM;
 
@@ -270,7 +270,8 @@ static int efx_sriov_memcpy(struct efx_nic *efx, struct efx_memcpy_req *req,
 			from_lo = (u32)req->from_addr;
 			from_hi = (u32)(req->from_addr >> 32);
 		} else {
-			if (WARN_ON(used + req->length > MCDI_CTL_SDU_LEN_MAX)) {
+			if (WARN_ON(used + req->length >
+				    MCDI_CTL_SDU_LEN_MAX_V1)) {
 				rc = -ENOBUFS;
 				goto out;
 			}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
