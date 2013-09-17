From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] p54usb: fix leak at failure path in p54u_load_firmware()
Date: Wed, 18 Sep 2013 00:57:59 +0400
Message-ID: <1379451479-31107-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If request_firmware_nowait() fails in p54u_load_firmware(),
p54u_load_firmware_cb is not called and no one decrements usb_dev refcnt.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/p54/p54usb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index b9deef6..7fa81d1 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -979,6 +979,7 @@ static int p54u_load_firmware(struct ieee80211_hw *dev,
 	if (err) {
 		dev_err(&priv->udev->dev, "(p54usb) cannot load firmware %s "
 					  "(%d)!\n", p54u_fwlist[i].fw, err);
+		usb_put_dev(udev);
 	}
 
 	return err;
-- 
1.8.1.2
