From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: LED in shared mode does not blink
 during traffic
Date: Fri, 20 Sep 2013 16:46:57 -0700
Message-ID: <1379720822-6500-4-git-send-email-nsujir@broadcom.com>
References: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4806 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702Ab3ITXrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 19:47:14 -0400
In-Reply-To: <1379720822-6500-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the 5717, 5719, 5720 and 5762 devices, in shared link/activity mode,
the blink rate must be overridden with all bits set.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0155ac3..34cd0f5 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14927,6 +14927,12 @@ static void tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			    tg3_chip_rev_id(tp) != CHIPREV_ID_5750_A1)
 				tp->led_ctrl |= (LED_CTRL_MODE_PHY_1 |
 						 LED_CTRL_MODE_PHY_2);
+
+			if (tg3_flag(tp, 5717_PLUS) ||
+			    tg3_asic_rev(tp) == ASIC_REV_5762)
+				tp->led_ctrl |= LED_CTRL_BLINK_RATE_OVERRIDE |
+						LED_CTRL_BLINK_RATE_MASK;
+
 			break;
 
 		case SHASTA_EXT_LED_MAC:
-- 
1.8.1.4
