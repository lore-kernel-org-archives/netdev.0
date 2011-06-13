From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/8] tg3: Add more selfboot formats to NVRAM
 selftest
Date: Mon, 13 Jun 2011 16:38:58 -0700
Message-ID: <1308008342-21030-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1285 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365Ab1FMXiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:38:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds more selfboot formats to the NVRAM selftest.  It also
changes the code to return an error on an unsupported NVRAM format.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 765f3dc..7ce50e5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10468,6 +10468,9 @@ error:
 #define NVRAM_SELFBOOT_FORMAT1_0_SIZE	0x14
 #define NVRAM_SELFBOOT_FORMAT1_2_SIZE	0x18
 #define NVRAM_SELFBOOT_FORMAT1_3_SIZE	0x1c
+#define NVRAM_SELFBOOT_FORMAT1_4_SIZE	0x20
+#define NVRAM_SELFBOOT_FORMAT1_5_SIZE	0x24
+#define NVRAM_SELFBOOT_FORMAT1_6_SIZE	0x4c
 #define NVRAM_SELFBOOT_HW_SIZE 0x20
 #define NVRAM_SELFBOOT_DATA_SIZE 0x1c
 
@@ -10498,8 +10501,17 @@ static int tg3_test_nvram(struct tg3 *tp)
 			case TG3_EEPROM_SB_REVISION_3:
 				size = NVRAM_SELFBOOT_FORMAT1_3_SIZE;
 				break;
+			case TG3_EEPROM_SB_REVISION_4:
+				size = NVRAM_SELFBOOT_FORMAT1_4_SIZE;
+				break;
+			case TG3_EEPROM_SB_REVISION_5:
+				size = NVRAM_SELFBOOT_FORMAT1_5_SIZE;
+				break;
+			case TG3_EEPROM_SB_REVISION_6:
+				size = NVRAM_SELFBOOT_FORMAT1_6_SIZE;
+				break;
 			default:
-				return 0;
+				return -EIO;
 			}
 		} else
 			return 0;
-- 
1.7.3.4


