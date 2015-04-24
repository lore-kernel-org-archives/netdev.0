From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 4.1] rtlwifi: rtl8192cu: Fix kernel deadlock
Date: Fri, 24 Apr 2015 11:03:37 -0500
Message-ID: <1429891417-1224-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Bernhard Wiedemann <bwiedemann@suse.com>,
	Takashi Iwai <tiwai@suse.com>
To: kvalo@codeaurora.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The USB mini-driver in rtlwifi, which is used by rtl8192cu, issues a call to
usb_control_msg() with a timeout value of 0. In some instances where the
interface is shutting down, this infinite wait results in a CPU deadlock. A
one second timeout fixes this problem without affecting any normal operations.

This bug is reported at https://bugzilla.novell.com/show_bug.cgi?id=927786.

Reported-by: Bernhard Wiedemann <bwiedemann@suse.com>
Tested-by: Bernhard Wiedemann <bwiedemann@suse.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
Cc: Bernhard Wiedemann <bwiedemann@suse.com>
Cc: Takashi Iwai<tiwai@suse.com>
---

Kalle,

I marked this patch for V4.1, and I hope that timing can be met.

Thanks,

Larry
---

 drivers/net/wireless/rtlwifi/usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 46ee956..27cd6ca 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -126,7 +126,7 @@ static int _usbctrl_vendorreq_sync_read(struct usb_device *udev, u8 request,
 
 	do {
 		status = usb_control_msg(udev, pipe, request, reqtype, value,
-					 index, pdata, len, 0); /*max. timeout*/
+					 index, pdata, len, 1000);
 		if (status < 0) {
 			/* firmware download is checksumed, don't retry */
 			if ((value >= FW_8192C_START_ADDRESS &&
-- 
2.1.4
