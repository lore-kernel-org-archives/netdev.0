From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: revert changes to NIC revision numbers
Date: Fri, 12 May 2017 17:18:50 +0100
Message-ID: <5a87b5cf-1696-0fbc-209d-95fa85023918@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:46980 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758081AbdELQTA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 12:19:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

The revision enum values (eg EFX_REV_HUNT_A0) form part of our API,
 and are included in ethtool. If these are inconsistent then ethtool
 will print garbage for a register dump (ethtool -d).

Fixes: 5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.h | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 7b916aa..4d7fb8a 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -18,8 +18,12 @@
 #include "mcdi.h"
 
 enum {
-	EFX_REV_SIENA_A0 = 0,
-	EFX_REV_HUNT_A0 = 1,
+	/* Revisions 0-2 were Falcon A0, A1 and B0 respectively.
+	 * They are not supported by this driver but these revision numbers
+	 * form part of the ethtool API for register dumping.
+	 */
+	EFX_REV_SIENA_A0 = 3,
+	EFX_REV_HUNT_A0 = 4,
 };
 
 static inline int efx_nic_rev(struct efx_nic *efx)
