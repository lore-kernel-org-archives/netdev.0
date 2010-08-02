From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/14] tg3: Detect APE firmware types
Date: Mon, 2 Aug 2010 14:26:01 -0700
Message-ID: <1280784368-4226-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2892 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755457Ab0HBV0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to determine the APE firmware type and report this
along with the firmware version.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    9 ++++++++-
 drivers/net/tg3.h |    2 ++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7c2c81a..a52f52f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12710,6 +12710,7 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 {
 	int vlen;
 	u32 apedata;
+	char *fwtype;
 
 	if (!(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) ||
 	    !(tp->tg3_flags  & TG3_FLAG_ENABLE_ASF))
@@ -12725,9 +12726,15 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 
 	apedata = tg3_ape_read32(tp, TG3_APE_FW_VERSION);
 
+	if (tg3_ape_read32(tp, TG3_APE_FW_FEATURES) & TG3_APE_FW_FEATURE_NCSI)
+		fwtype = "NCSI";
+	else
+		fwtype = "DASH";
+
 	vlen = strlen(tp->fw_ver);
 
-	snprintf(&tp->fw_ver[vlen], TG3_VER_SIZE - vlen, " DASH v%d.%d.%d.%d",
+	snprintf(&tp->fw_ver[vlen], TG3_VER_SIZE - vlen, " %s v%d.%d.%d.%d",
+		 fwtype,
 		 (apedata & APE_FW_VERSION_MAJMSK) >> APE_FW_VERSION_MAJSFT,
 		 (apedata & APE_FW_VERSION_MINMSK) >> APE_FW_VERSION_MINSFT,
 		 (apedata & APE_FW_VERSION_REVMSK) >> APE_FW_VERSION_REVSFT,
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a7b8ec7..53b6def 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2161,6 +2161,8 @@
 /* APE shared memory.  Accessible through BAR1 */
 #define TG3_APE_FW_STATUS		0x400c
 #define  APE_FW_STATUS_READY		 0x00000100
+#define TG3_APE_FW_FEATURES		0x4010
+#define  TG3_APE_FW_FEATURE_NCSI	 0x00000002
 #define TG3_APE_FW_VERSION		0x4018
 #define  APE_FW_VERSION_MAJMSK		 0xff000000
 #define  APE_FW_VERSION_MAJSFT		 24
-- 
1.7.1


