From: Emil Goode <emilgoode@gmail.com>
Subject: [PATCH 2/2] net: asix: add missing flag to struct driver_info
Date: Mon, 10 Feb 2014 00:06:14 +0100
Message-ID: <1391987174-21828-2-git-send-email-emilgoode@gmail.com>
References: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, Emil Goode <emilgoode@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391987174-21828-1-git-send-email-emilgoode@gmail.com>
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
 drivers/net/usb/asix_devices.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devi=
ces.c
index 7ced4ed..19d8821 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -919,7 +919,7 @@ static const struct driver_info ax88178_info =3D {
 	.link_reset =3D ax88178_link_reset,
 	.reset =3D ax88178_reset,
 	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
-		 FLAG_PARTIAL_RX_PKT,
+		 FLAG_MULTI_PACKET | FLAG_PARTIAL_RX_PKT,
 	.rx_fixup =3D asix_rx_fixup_common,
 	.tx_fixup =3D asix_tx_fixup,
 };
--=20
1.7.10.4
