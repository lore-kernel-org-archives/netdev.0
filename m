From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] sfc: tx ring can only have 2048 entries for all EF10 NICs
Date: Tue, 25 Apr 2017 13:44:54 +0100
Message-ID: <8a13989f-959d-7d93-c9a7-7e890514d99c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
        "Patrick Talbert" <ptalbert@redhat.com>
To: Dave Miller <davem@davemloft.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:56695 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1430464AbdDYMqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 08:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: dd248f1bc65b ("sfc: Add PCI ID for Solarflare 8000 series 10/40G NIC")
Reported-by: Patrick Talbert <ptalbert@redhat.com>
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h         | 5 ++++-
 drivers/net/ethernet/sfc/workarounds.h | 1 +
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index ee14662415c5..a0c52e328102 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -74,7 +74,10 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 #define EFX_RXQ_MIN_ENT		128U
 #define EFX_TXQ_MIN_ENT(efx)	(2 * efx_tx_max_skb_descs(efx))
 
-#define EFX_TXQ_MAX_ENT(efx)	(EFX_WORKAROUND_35388(efx) ? \
+/* All EF10 architecture NICs steal one bit of the DMAQ size for various
+ * other purposes when counting TxQ entries, so we halve the queue size.
+ */
+#define EFX_TXQ_MAX_ENT(efx)	(EFX_WORKAROUND_EF10(efx) ? \
 				 EFX_MAX_DMAQ_SIZE / 2 : EFX_MAX_DMAQ_SIZE)
 
 static inline bool efx_rss_enabled(struct efx_nic *efx)
diff --git a/drivers/net/ethernet/sfc/workarounds.h b/drivers/net/ethernet/sfc/workarounds.h
index 103f827a1623..c67fa18b8121 100644
--- a/drivers/net/ethernet/sfc/workarounds.h
+++ b/drivers/net/ethernet/sfc/workarounds.h
@@ -16,6 +16,7 @@
  */
 
 #define EFX_WORKAROUND_SIENA(efx) (efx_nic_rev(efx) == EFX_REV_SIENA_A0)
+#define EFX_WORKAROUND_EF10(efx) (efx_nic_rev(efx) >= EFX_REV_HUNT_A0)
 #define EFX_WORKAROUND_10G(efx) 1
 
 /* Bit-bashed I2C reads cause performance drop */
-- 
2.7.4
