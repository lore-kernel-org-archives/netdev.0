From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH] net: usb: ch9200: use kmemdup
Date: Thu, 19 May 2016 19:26:50 +0530
Message-ID: <1463666221-16631-1-git-send-email-falakreyaz@gmail.com>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tobias Klauser <tklauser@distanz.ch>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kmemdup when some other buffer is immediately copied into allocated
region. It replaces call to allocation followed by memcpy, by a single
call to kmemdup.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 drivers/net/usb/ch9200.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/ch9200.c b/drivers/net/usb/ch9200.c
index 5e151e6..8a40202 100644
--- a/drivers/net/usb/ch9200.c
+++ b/drivers/net/usb/ch9200.c
@@ -155,12 +155,11 @@ static int control_write(struct usbnet *dev, unsigned char request,
 		   index, size);
 
 	if (data) {
-		buf = kmalloc(size, GFP_KERNEL);
+		buf = kmemdup(data, size, GFP_KERNEL);
 		if (!buf) {
 			err = -ENOMEM;
 			goto err_out;
 		}
-		memcpy(buf, data, size);
 	}
 
 	err = usb_control_msg(dev->udev,
-- 
1.9.1
