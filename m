From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers/net/irda/Kconfig: Let SH_IRDA depend on HAS_IOMEM
Date: Thu, 02 Oct 2014 22:32:56 +0800
Message-ID: <542D6218.3040609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Weinberger <richard@nod.at>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SH_IRDA needs HAS_IOMEM, so depend on it. The related error(with
allmodconfig under um):

    CC [M]  drivers/net/irda/sh_irda.o
  drivers/net/irda/sh_irda.c: In function =E2=80=98sh_irda_probe=E2=80=99=
:
  drivers/net/irda/sh_irda.c:776:2: error: implicit declaration of func=
tion =E2=80=98ioremap_nocache=E2=80=99 [-Werror=3Dimplicit-function-dec=
laration]
    self->membase =3D ioremap_nocache(res->start, resource_size(res));
    ^
  drivers/net/irda/sh_irda.c:776:16: warning: assignment makes pointer =
from integer without a cast [enabled by default]
    self->membase =3D ioremap_nocache(res->start, resource_size(res));
                  ^
  drivers/net/irda/sh_irda.c:821:2: error: implicit declaration of func=
tion =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaration=
]
    iounmap(self->membase);
    ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/irda/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 8d101d6..a2c227b 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -397,7 +397,7 @@ config MCS_FIR
 config SH_IRDA
 	tristate "SuperH IrDA driver"
 	depends on IRDA
-	depends on ARCH_SHMOBILE || COMPILE_TEST
+	depends on (ARCH_SHMOBILE || COMPILE_TEST) && HAS_IOMEM
 	help
 	  Say Y here if your want to enable SuperH IrDA devices.
=20
--=20
1.9.3
