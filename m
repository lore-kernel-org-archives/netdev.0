From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 4/5] tg3: Expand multicast drop counter miscounting fix to 5762
Date: Fri, 6 Dec 2013 09:53:19 -0800
Message-ID: <1386352400-9623-5-git-send-email-nsujir@broadcom.com>
References: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:34927 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab3LFRxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:53:33 -0500
In-Reply-To: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4d95847381228639844c7197deb8b2211274ef22 - "tg3: Workaround
rx_discards stat bug", added a workaround for miscounted statistics for
multicast packets. This fix needs to be applied to the 5762.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e8847cc..7cba139 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9969,6 +9969,7 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 	if (tg3_asic_rev(tp) == ASIC_REV_5719)
 		val |= BUFMGR_MODE_NO_TX_UNDERRUN;
 	if (tg3_asic_rev(tp) == ASIC_REV_5717 ||
+	    tg3_asic_rev(tp) == ASIC_REV_5762 ||
 	    tg3_chip_rev_id(tp) == CHIPREV_ID_5719_A0 ||
 	    tg3_chip_rev_id(tp) == CHIPREV_ID_5720_A0)
 		val |= BUFMGR_MODE_MBLOW_ATTN_ENAB;
@@ -10754,6 +10755,7 @@ static void tg3_periodic_fetch_stats(struct tg3 *tp)
 
 	TG3_STAT_ADD32(&sp->rxbds_empty, RCVLPC_NO_RCV_BD_CNT);
 	if (tg3_asic_rev(tp) != ASIC_REV_5717 &&
+	    tg3_asic_rev(tp) != ASIC_REV_5762 &&
 	    tg3_chip_rev_id(tp) != CHIPREV_ID_5719_A0 &&
 	    tg3_chip_rev_id(tp) != CHIPREV_ID_5720_A0) {
 		TG3_STAT_ADD32(&sp->rx_discards, RCVLPC_IN_DISCARDS_CNT);
@@ -16545,6 +16547,7 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
 
 	/* Set these bits to enable statistics workaround. */
 	if (tg3_asic_rev(tp) == ASIC_REV_5717 ||
+	    tg3_asic_rev(tp) == ASIC_REV_5762 ||
 	    tg3_chip_rev_id(tp) == CHIPREV_ID_5719_A0 ||
 	    tg3_chip_rev_id(tp) == CHIPREV_ID_5720_A0) {
 		tp->coalesce_mode |= HOSTCC_MODE_ATTN;
-- 
1.8.1.4
