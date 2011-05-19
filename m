From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 12/13] tg3: Apply rx_discards fix to 5719/5720
Date: Thu, 19 May 2011 15:12:55 -0700
Message-ID: <1305843176-32358-13-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1124 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934962Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4d95847381228639844c7197deb8b2211274ef22, entitled
"tg3: Workaround rx_discards stat bug", was intended to be applied to
the 5717, 5718, 5719_A0, and 5720 A0 chip revisions.  The implementation
missed the latter two when applying the fix in a critical area.  This
patch fixes the problem.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eb8dc7b..8311f8e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8797,7 +8797,9 @@ static void tg3_periodic_fetch_stats(struct tg3 *tp)
 	TG3_STAT_ADD32(&sp->rx_undersize_packets, MAC_RX_STATS_UNDERSIZE);
 
 	TG3_STAT_ADD32(&sp->rxbds_empty, RCVLPC_NO_RCV_BD_CNT);
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
+	    tp->pci_chip_rev_id != CHIPREV_ID_5719_A0 &&
+	    tp->pci_chip_rev_id != CHIPREV_ID_5720_A0) {
 		TG3_STAT_ADD32(&sp->rx_discards, RCVLPC_IN_DISCARDS_CNT);
 	} else {
 		u32 val = tr32(HOSTCC_FLOW_ATTN);
-- 
1.7.3.4


