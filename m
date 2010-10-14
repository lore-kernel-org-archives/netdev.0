From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Disable unused transmit rings
Date: Thu, 14 Oct 2010 13:37:39 -0700
Message-ID: <1287088665-22135-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2061 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756011Ab0JNUiB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:38:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the driver to disable the additional transmit rings
available on the 5717 and 5719 devices.  This is not strictly necessary,
but is done anyways for correctness.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 978ba5d..1c680ff 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7536,6 +7536,9 @@ static void tg3_rings_reset(struct tg3 *tp)
 	/* Disable all transmit rings but the first. */
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 16;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+		 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
+		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 4;
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 		limit = NIC_SRAM_SEND_RCB + TG3_BDINFO_SIZE * 2;
 	else
-- 
1.7.2.2


