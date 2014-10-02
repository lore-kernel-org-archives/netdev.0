From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers/net/can/Kconfig: Let CAN_AT91 depend on HAS_IOMEM
Date: Thu, 02 Oct 2014 22:01:42 +0800
Message-ID: <542D5AC6.4010404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: wg@grandegger.com, mkl@pengutronix.de,
	Richard Weinberger <richard@nod.at>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CAN_AT91 needs HAS_IOMEM, so depends on it. The related error (with
allmodconfig under um):

    CC [M]  drivers/net/can/at91_can.o
  drivers/net/can/at91_can.c: In function =E2=80=98at91_can_probe=E2=80=
=99:
  drivers/net/can/at91_can.c:1329:2: error: implicit declaration of fun=
ction =E2=80=98ioremap_nocache=E2=80=99 [-Werror=3Dimplicit-function-de=
claration]
  addr =3D ioremap_nocache(res->start, resource_size(res));
    ^
  drivers/net/can/at91_can.c:1329:7: warning: assignment makes pointer =
from integer without a cast [enabled by default]
    addr =3D ioremap_nocache(res->start, resource_size(res));
         ^
  drivers/net/can/at91_can.c:1384:2: error: implicit declaration of fun=
ction =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaratio=
n]
    iounmap(addr);
    ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/can/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index e78d6b3..98d73aa 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -65,7 +65,7 @@ config CAN_LEDS
=20
 config CAN_AT91
 	tristate "Atmel AT91 onchip CAN controller"
-	depends on ARCH_AT91 || COMPILE_TEST
+	depends on (ARCH_AT91 || COMPILE_TEST) && HAS_IOMEM
 	---help---
 	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263
 	  and AT91SAM9X5 processors.
--=20
1.9.3
