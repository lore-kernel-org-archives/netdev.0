From: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Subject: [PATCH v2 2/2] rt2800usb:fix hang during firmware load
Date: Thu, 12 Jun 2014 19:33:41 +0200
Message-ID: <20140612173341.15935.7058.stgit@charlie.fem.tu-ilmenau.de>
References: <20140612173057.15935.14194.stgit@charlie.fem.tu-ilmenau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140612173057.15935.14194.stgit-T1IWWRiYoUTeQ37wNh6nHvMwkO6i8y0ws0AfqQuZ5sE@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The device 057c:8501 (AVM Fritz! WLAN v2 rev. B) boots into a state that does
not actually require loading a firmware file. The vendors driver finds out
about this by checking a firmware state register, so this patch adds this here.

Finally, with this patch applied, my wifi dongle actually becomes
useful (scan + connect to wpa network works).

Signed-off-by: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
---
 drivers/net/wireless/rt2x00/rt2800usb.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 11583ca..e11dab2 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -278,8 +278,13 @@ static int rt2800usb_write_firmware(struct rt2x00_dev *rt2x00dev,
 	/*
 	 * Write firmware to device.
 	 */
-	rt2x00usb_register_multiwrite(rt2x00dev, FIRMWARE_IMAGE_BASE,
-				      data + offset, length);
+	if (rt2800usb_autorun_detect(rt2x00dev)) {
+		rt2x00_info(rt2x00dev,
+			    "Firmware loading not required - NIC in AutoRun mode\n");
+	} else {
+		rt2x00usb_register_multiwrite(rt2x00dev, FIRMWARE_IMAGE_BASE,
+					      data + offset, length);
+	}
 
 	rt2x00usb_register_write(rt2x00dev, H2M_MAILBOX_CID, ~0);
 	rt2x00usb_register_write(rt2x00dev, H2M_MAILBOX_STATUS, ~0);

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
