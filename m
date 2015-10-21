From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 08/15] net: wireless: simplify return flow for usb_control_msg
Date: Wed, 21 Oct 2015 20:25:30 +0530
Message-ID: <1445439337-19055-9-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the at76c50x-usb.c file that fixes up warning
reported by coccicheck:

WARNING: end returns can be simplified if negative or 0 value

Prefer direct return value instead of writing 2-3 more sentence.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/at76c50x-usb.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index dab2513..09427f6 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -544,13 +544,10 @@ static void at76_ledtrig_tx_activity(void)
 static int at76_remap(struct usb_device *udev)
 {
 	int ret;
-	ret = usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x0a,
+	return usb_control_msg(udev, usb_sndctrlpipe(udev, 0), 0x0a,
 			      USB_TYPE_VENDOR | USB_DIR_OUT |
 			      USB_RECIP_INTERFACE, 0, 0, NULL, 0,
 			      USB_CTRL_GET_TIMEOUT);
-	if (ret < 0)
-		return ret;
-	return 0;
 }
 
 static int at76_get_op_mode(struct usb_device *udev)
-- 
2.5.3
