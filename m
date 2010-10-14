From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/8] tg3: Add support for selfboot format 1 v6
Date: Thu, 14 Oct 2010 13:37:38 -0700
Message-ID: <1287088665-22135-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2371 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755882Ab0JNUh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:37:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

5718 B0 and 5719 devices will use a new selfboot firmware format.  This
patch adds code to detect the new format so that bootcode versions get
reported correctly.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 drivers/net/tg3.h |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 943c283..978ba5d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12702,6 +12702,9 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 	case TG3_EEPROM_SB_REVISION_5:
 		offset = TG3_EEPROM_SB_F1R5_EDH_OFF;
 		break;
+	case TG3_EEPROM_SB_REVISION_6:
+		offset = TG3_EEPROM_SB_F1R6_EDH_OFF;
+		break;
 	default:
 		return;
 	}
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f6b709a..89553c4 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1915,6 +1915,7 @@
 #define TG3_EEPROM_SB_REVISION_3	0x00030000
 #define TG3_EEPROM_SB_REVISION_4	0x00040000
 #define TG3_EEPROM_SB_REVISION_5	0x00050000
+#define TG3_EEPROM_SB_REVISION_6	0x00060000
 #define TG3_EEPROM_MAGIC_HW		0xabcd
 #define TG3_EEPROM_MAGIC_HW_MSK		0xffff
 
@@ -1934,6 +1935,7 @@
 #define TG3_EEPROM_SB_F1R3_EDH_OFF	0x18
 #define TG3_EEPROM_SB_F1R4_EDH_OFF	0x1c
 #define TG3_EEPROM_SB_F1R5_EDH_OFF	0x20
+#define TG3_EEPROM_SB_F1R6_EDH_OFF	0x4c
 #define TG3_EEPROM_SB_EDH_MAJ_MASK	0x00000700
 #define TG3_EEPROM_SB_EDH_MAJ_SHFT	8
 #define TG3_EEPROM_SB_EDH_MIN_MASK	0x000000ff
-- 
1.7.2.2


