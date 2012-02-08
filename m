From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH] rtlwifi: rtl8192se firmware load can overflow target buffer
Date: Wed,  8 Feb 2012 14:08:10 -0700
Message-ID: <1328735291-33220-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The firmware file size check does not use the
correct limit.

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h |    3 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
index babe85d..5c377fc 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
@@ -30,6 +30,7 @@
 #define __REALTEK_FIRMWARE92S_H__
 
 #define RTL8190_MAX_FIRMWARE_CODE_SIZE		64000
+#define RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE	164000
 #define RTL8190_CPU_START_OFFSET		0x80
 /* Firmware Local buffer size. 64k */
 #define	MAX_FIRMWARE_CODE_SIZE			0xFF00
@@ -217,7 +218,7 @@ struct rt_firmware {
 	u8 fw_emem[RTL8190_MAX_FIRMWARE_CODE_SIZE];
 	u32 fw_imem_len;
 	u32 fw_emem_len;
-	u8 sz_fw_tmpbuffer[164000];
+	u8 sz_fw_tmpbuffer[RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE];
 	u32 sz_fw_tmpbufferlen;
 	u16 cmdpacket_fragthresold;
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index ca38dd9..155da0a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -105,7 +105,7 @@ static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
 		rtlpriv->max_fw_size = 0;
 		return;
 	}
-	if (firmware->size > rtlpriv->max_fw_size) {
+	if (firmware->size >= RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Firmware is too big!\n");
 		release_firmware(firmware);
-- 
1.7.9
