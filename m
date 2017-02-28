From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: usb: asix_devices: fix missing return code check on call to asix_write_medium_mode
Date: Tue, 28 Feb 2017 11:58:22 +0000
Message-ID: <20170228115822.20485-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Robert Foss <robert.foss@collabora.com>,
        Grant Grundler <grundler@google.com>,
        allan <allan@asix.com.tw>,
        Vincent Palatin <vpalatin@chromium.org>,
        Jarod Wilson <jarod@redhat.com>,
        Peter Chen <peter.chen@nxp.com>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The call to asix_write_medium_mode is not updating the return code ret
and yet ret is being checked for an error. Fix this by assigning ret to
the return code from the call asix_write_medium_mode.

Detected by CoverityScan, CID#1357148 ("Logically Dead Code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/usb/asix_devices.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 6e98ede..0dd5106 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -346,7 +346,7 @@ static int ax88772_reset(struct usbnet *dev)
 	if (ret < 0)
 		goto out;
 
-	asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT, 0);
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT, 0);
 	if (ret < 0)
 		goto out;
 
-- 
2.10.2
