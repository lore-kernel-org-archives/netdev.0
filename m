From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/17] sfc: Log specific message for failure of NVRAM
 self-test
Date: Wed, 28 Apr 2010 20:28:36 +0100
Message-ID: <1272482916.2549.23.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12488 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0D1T2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:28:39 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 1344afa..93cc3c1 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -932,20 +932,26 @@ int efx_mcdi_nvram_test_all(struct efx_nic *efx)
 
 	rc = efx_mcdi_nvram_types(efx, &nvram_types);
 	if (rc)
-		return rc;
+		goto fail1;
 
 	type = 0;
 	while (nvram_types != 0) {
 		if (nvram_types & 1) {
 			rc = efx_mcdi_nvram_test(efx, type);
 			if (rc)
-				return rc;
+				goto fail2;
 		}
 		type++;
 		nvram_types >>= 1;
 	}
 
 	return 0;
+
+fail2:
+	EFX_ERR(efx, "%s: failed type=%u\n", __func__, type);
+fail1:
+	EFX_ERR(efx, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
 }
 
 static int efx_mcdi_read_assertion(struct efx_nic *efx)
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

