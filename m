From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 12/14] tg3: Add version reporting for hardware selfboot
Date: Wed, 25 Feb 2009 16:27:43 -0800
Message-ID: <1235616379.16028@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1875 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027AbZBZCqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds version reporting for hardware selfboot.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   18 ++++++++++++++++++
 drivers/net/tg3.h |    6 ++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bbf5fe3..d12338f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11509,6 +11509,22 @@ static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 	}
 }
 
+static void __devinit tg3_read_hwsb_ver(struct tg3 *tp)
+{
+	u32 val, major, minor;
+
+	/* Use native endian representation */
+	if (tg3_nvram_read(tp, TG3_NVM_HWSB_CFG1, &val))
+		return;
+
+	major = (val & TG3_NVM_HWSB_CFG1_MAJMSK) >>
+		TG3_NVM_HWSB_CFG1_MAJSFT;
+	minor = (val & TG3_NVM_HWSB_CFG1_MINMSK) >>
+		TG3_NVM_HWSB_CFG1_MINSFT;
+
+	snprintf(&tp->fw_ver[0], 32, "sb v%d.%02d", major, minor);
+}
+
 static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 {
 	u32 offset, major, minor, build;
@@ -11645,6 +11661,8 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 		tg3_read_bc_ver(tp);
 	else if ((val & TG3_EEPROM_MAGIC_FW_MSK) == TG3_EEPROM_MAGIC_FW)
 		tg3_read_sb_ver(tp, val);
+	else if ((val & TG3_EEPROM_MAGIC_HW_MSK) == TG3_EEPROM_MAGIC_HW)
+		tg3_read_hwsb_ver(tp);
 	else
 		return;
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 2a75a60..cb4c62a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1719,6 +1719,12 @@
 
 #define TG3_OTP_DEFAULT			0x286c1640
 
+/* Hardware Selfboot NVRAM layout */
+#define TG3_NVM_HWSB_CFG1		0x00000004
+#define  TG3_NVM_HWSB_CFG1_MAJMSK	0xf8000000
+#define  TG3_NVM_HWSB_CFG1_MAJSFT	27
+#define  TG3_NVM_HWSB_CFG1_MINMSK	0x07c00000
+#define  TG3_NVM_HWSB_CFG1_MINSFT	22
 
 #define TG3_EEPROM_MAGIC		0x669955aa
 #define TG3_EEPROM_MAGIC_FW		0xa5000000
-- 
1.6.0.6


