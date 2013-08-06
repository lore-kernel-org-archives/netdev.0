From: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH] zd1201: do not use stack as URB transfer_buffer
Date: Tue, 06 Aug 2013 14:28:42 +0300
Message-ID: <20130806112842.14897.95337.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Patch fixes zd1201 not to use stack as URB transfer_buffer. URB buffers need
to be DMA-able, which stack is not.

Patch is only compile tested.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
---
 drivers/net/wireless/zd1201.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 4941f20..b8ba1f9 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -98,10 +98,12 @@ static int zd1201_fw_upload(struct usb_device *dev, int apfw)
 		goto exit;
 
 	err = usb_control_msg(dev, usb_rcvctrlpipe(dev, 0), 0x4,
-	    USB_DIR_IN | 0x40, 0,0, &ret, sizeof(ret), ZD1201_FW_TIMEOUT);
+	    USB_DIR_IN | 0x40, 0, 0, buf, sizeof(ret), ZD1201_FW_TIMEOUT);
 	if (err < 0)
 		goto exit;
 
+	memcpy(&ret, buf, sizeof(ret));
+
 	if (ret & 0x80) {
 		err = -EIO;
 		goto exit;

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
