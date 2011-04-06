From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 net-next 9/9] tg3: Support 4mb flash sizes for 5717
 and 5719
Date: Tue, 5 Apr 2011 17:22:51 -0700
Message-ID: <1302049371-13799-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4466 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab1DFAQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 20:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a 5717 or 5719 NVRAM part is manually strapped and is 2mb in size,
the driver needs to look at the NVRAM size field rather than infer it
from the strapping itself.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a065beb..f944c6b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11866,6 +11866,8 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 
 		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 		case FLASH_5717VENDOR_ATMEL_MDB021D:
+			/* Detect size with tg3_nvram_get_size() */
+			break;
 		case FLASH_5717VENDOR_ATMEL_ADB021B:
 		case FLASH_5717VENDOR_ATMEL_ADB021D:
 			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
@@ -11891,8 +11893,10 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 
 		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
 		case FLASH_5717VENDOR_ST_M_M25PE20:
-		case FLASH_5717VENDOR_ST_A_M25PE20:
 		case FLASH_5717VENDOR_ST_M_M45PE20:
+			/* Detect size with tg3_nvram_get_size() */
+			break;
+		case FLASH_5717VENDOR_ST_A_M25PE20:
 		case FLASH_5717VENDOR_ST_A_M45PE20:
 			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
 			break;
-- 
1.7.3.4


