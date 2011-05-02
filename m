From: =?UTF-8?q?L=2E=20Alberto=20Gim=C3=A9nez?= <agimenez@sysvalve.es>
Subject: [PATCH] ipheth.c: Enable IP header alignment
Date: Mon,  2 May 2011 21:35:12 +0200
Message-ID: <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
References: <1304264799.2833.82.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dgiagio@gmail.com, dborca@yahoo.com, davem@davemloft.net,
	pmcenery@gmail.com, david.hill@ubisoft.com,
	linux-usb@vger.kernel.org (open list:USB SUBSYSTEM),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304264799.2833.82.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit ea812ca1b06113597adcd8e70c0f84a413d97544 (x86: Align skb w=
/ start
of cacheline on newer core 2/Xeon Arch), NET_IP_ALIGN changed from 2 to=
 0, and
the constant is used to reserve more room for the socket buffer.

Some people have reported that tethering stopped working and David Hill
submited a patch that redefined NET_IP_ALIGN. Pointed by Ben Hutchings,=
 the
patch has been reworked to use a private constant.

I have no more an iPhone device to test it, so it is only compile-teste=
d.

Signed-off-by: L. Alberto Gim=C3=A9nez <agimenez@sysvalve.es>
---
 drivers/net/usb/ipheth.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
index 7d42f9a..8f1ffc7 100644
--- a/drivers/net/usb/ipheth.c
+++ b/drivers/net/usb/ipheth.c
@@ -80,6 +80,8 @@
 #define IPHETH_CARRIER_CHECK_TIMEOUT round_jiffies_relative(1 * HZ)
 #define IPHETH_CARRIER_ON       0x04
=20
+#define IPHETH_IP_ALIGN 2
+
 static struct usb_device_id ipheth_table[] =3D {
 	{ USB_DEVICE_AND_INTERFACE_INFO(
 		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE,
@@ -205,15 +207,15 @@ static void ipheth_rcvbulk_callback(struct urb *u=
rb)
 	len =3D urb->actual_length;
 	buf =3D urb->transfer_buffer;
=20
-	skb =3D dev_alloc_skb(NET_IP_ALIGN + len);
+	skb =3D dev_alloc_skb(IPHETH_IP_ALIGN + len);
 	if (!skb) {
 		err("%s: dev_alloc_skb: -ENOMEM", __func__);
 		dev->net->stats.rx_dropped++;
 		return;
 	}
=20
-	skb_reserve(skb, NET_IP_ALIGN);
-	memcpy(skb_put(skb, len), buf + NET_IP_ALIGN, len - NET_IP_ALIGN);
+	skb_reserve(skb, IPHETH_IP_ALIGN);
+	memcpy(skb_put(skb, len), buf + IPHETH_IP_ALIGN, len - IPHETH_IP_ALIG=
N);
 	skb->dev =3D dev->net;
 	skb->protocol =3D eth_type_trans(skb, dev->net);
=20
--=20
1.7.5
