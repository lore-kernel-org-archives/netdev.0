From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/11][TG3]: Clear GPIO mask before storing.
Date: Fri, 04 May 2007 17:52:38 -0700
Message-ID: <1178326358.4859.19.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3589 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767923AbXEEAFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:05:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Clear GPIO mask before storing.

The GPIO settings may change during reset and so the stored values in
tp->grc_local_ctrl should be cleared first.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c01bd86..00027a1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6454,6 +6454,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 			gpio_mask |= GRC_LCLCTRL_GPIO_UART_SEL;
 
+		tp->grc_local_ctrl &= ~gpio_mask;
 		tp->grc_local_ctrl |= tr32(GRC_LOCAL_CTRL) & gpio_mask;
 
 		/* GPIO1 must be driven high for eeprom write protect */


