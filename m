From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 02/11] tg3: Fix NVRAM size detection for the
 STM45PE20 pinstrap on 5762 devices
Date: Tue, 9 Apr 2013 11:48:02 -0700
Message-ID: <1365533291-5672-3-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2277 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934538Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

The STM45PE20 pinstrap on 5762 devices supports multiple sizes. So treat
it just like the ST45_USPT and the size will be read from 0xf0 via
tg3_get_nvram_size().

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d044adf..a27310d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13986,6 +13986,12 @@ static void tg3_get_5720_nvram_info(struct tg3 *tp)
 		case FLASH_5762_EEPROM_LD:
 			nvmpinstrp = FLASH_5720_EEPROM_LD;
 			break;
+		case FLASH_5720VENDOR_M_ST_M45PE20:
+			/* This pinstrap supports multiple sizes, so force it
+			 * to read the actual size from location 0xf0.
+			 */
+			nvmpinstrp = FLASH_5720VENDOR_ST_45USPT;
+			break;
 		}
 	}
 
-- 
1.8.1.4
