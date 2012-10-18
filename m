From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 01/14] net: usbnet: make sure the queue lenght is at least 1
Date: Thu, 18 Oct 2012 22:40:54 +0200
Message-ID: <1350592867-25651-2-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60316 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216Ab2JRUm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 16:42:26 -0400
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some usbnet based devices may want to use a rx_urb_size
greater than RX_MAX_QUEUE_MEMORY.  Prevent this from
creating a zero length rx queue.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/usbnet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f9819d1..34b5205 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -65,9 +65,9 @@
  */
 #define RX_MAX_QUEUE_MEMORY (60 * 1518)
 #define	RX_QLEN(dev) (((dev)->udev->speed =3D=3D USB_SPEED_HIGH) ? \
-			(RX_MAX_QUEUE_MEMORY/(dev)->rx_urb_size) : 4)
+			(1 + RX_MAX_QUEUE_MEMORY/(dev)->rx_urb_size) : 4)
 #define	TX_QLEN(dev) (((dev)->udev->speed =3D=3D USB_SPEED_HIGH) ? \
-			(RX_MAX_QUEUE_MEMORY/(dev)->hard_mtu) : 4)
+			(1 + RX_MAX_QUEUE_MEMORY/(dev)->hard_mtu) : 4)
=20
 // reawaken network queue this soon after stopping; else watchdog bark=
s
 #define TX_TIMEOUT_JIFFIES	(5*HZ)
--=20
1.7.10.4
