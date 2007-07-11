From: "Michael Chan" <mchan@broadcom.com>
Subject: [4/5][TG3]: Add missing NVRAM strapping.
Date: Wed, 11 Jul 2007 16:32:25 -0700
Message-ID: <1184196745.5211.11.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, mcarlson@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2770 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932673AbXGKWkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 18:40:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add missing NVRAM strapping.

This patch adds a missing NVRAM strapping for 5755 devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4f59e5c..0d40f9d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9461,11 +9461,13 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 		case FLASH_5755VENDOR_ATMEL_FLASH_1:
 		case FLASH_5755VENDOR_ATMEL_FLASH_2:
 		case FLASH_5755VENDOR_ATMEL_FLASH_3:
+		case FLASH_5755VENDOR_ATMEL_FLASH_5:
 			tp->nvram_jedecnum = JEDEC_ATMEL;
 			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
 			tp->tg3_flags2 |= TG3_FLG2_FLASH;
 			tp->nvram_pagesize = 264;
-			if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_1)
+			if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_1 ||
+			    nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_5)
 				tp->nvram_size = (protect ? 0x3e200 : 0x80000);
 			else if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_2)
 				tp->nvram_size = (protect ? 0x1f200 : 0x40000);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index e1b9381..d84e75e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1467,6 +1467,7 @@
 #define  FLASH_5755VENDOR_ATMEL_FLASH_2	 0x03400002
 #define  FLASH_5755VENDOR_ATMEL_FLASH_3	 0x03400000
 #define  FLASH_5755VENDOR_ATMEL_FLASH_4	 0x00000003
+#define  FLASH_5755VENDOR_ATMEL_FLASH_5	 0x02000003
 #define  FLASH_5755VENDOR_ATMEL_EEPROM_64KHZ	 0x03c00003
 #define  FLASH_5755VENDOR_ATMEL_EEPROM_376KHZ	 0x03c00002
 #define  FLASH_5787VENDOR_ATMEL_EEPROM_64KHZ	 0x03000003


