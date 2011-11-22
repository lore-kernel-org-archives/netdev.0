From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/4] tg3: Adjust BD replenish thresholds
Date: Mon, 21 Nov 2011 17:01:18 -0800
Message-ID: <1321923680-7925-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2489 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757639Ab1KVBCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 20:02:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BD replenish thresholds for the 57765 and newer ASIC revs are a
little strict.  They were tuned for a mode that is currently unused.
This patch relaxes the thresholds so that they are set to values more
inline with the resources available.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 438d099..096a67e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8171,7 +8171,8 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 	if (!tg3_flag(tp, 5750_PLUS) ||
 	    tg3_flag(tp, 5780_CLASS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
+	    tg3_flag(tp, 57765_PLUS))
 		bdcache_maxcnt = TG3_SRAM_RX_STD_BDCACHE_SIZE_5700;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
@@ -8191,10 +8192,7 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 	if (!tg3_flag(tp, JUMBO_CAPABLE) || tg3_flag(tp, 5780_CLASS))
 		return;
 
-	if (!tg3_flag(tp, 5705_PLUS))
-		bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5700;
-	else
-		bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5717;
+	bdcache_maxcnt = TG3_SRAM_RX_JMB_BDCACHE_SIZE_5700;
 
 	host_rep_thresh = max_t(u32, tp->rx_jumbo_pending / 8, 1);
 
-- 
1.7.3.4
