From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH Resend] net: asix: add missing flag to struct driver_info
Date: Thu, 13 Feb 2014 19:30:39 +0100
Message-ID: <1392316239-17335-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The struct driver_info ax88178_info is assigned the function
asix_rx_fixup_common as it's rx_fixup callback. This means that
=46LAG_MULTI_PACKET must be set as this function is cloning the
data and calling usbnet_skb_return. Not setting this flag leads
to usbnet_skb_return beeing called a second time from within
the rx_process function in the usbnet module.

Signed-off-by: Emil Goode <emilgoode@gmail.com>
Reported-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/asix_devices.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devi=
ces.c
index 9765a7d..5d19409 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -917,7 +917,8 @@ static const struct driver_info ax88178_info =3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88178_link_reset,
 	.reset =3D ax88178_reset,
-	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
+	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
+		 FLAG_MULTI_PACKET,
 	.rx_fixup =3D asix_rx_fixup_common,
 	.tx_fixup =3D asix_tx_fixup,
 };
--=20
1.7.10.4
