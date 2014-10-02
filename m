From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: [PATCH] drivers/net/ethernet/marvell/Kconfig: Let PXA168_ETH depend
 on HAS_IOMEM
Date: Thu, 02 Oct 2014 22:23:33 +0800
Message-ID: <542D5FE5.2040400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: davem@davemloft.net, antoine.tenart@free-electrons.com,
	arnd@arndb.de, jason@lakedaemon.net, richard@nod.at,
	mw@semihalf.com, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PXA168_ETH need HAS_IOMEM, so depend on it, the related error (with
allmodconfig under um):

    CC [M]  drivers/net/ethernet/marvell/pxa168_eth.o
  drivers/net/ethernet/marvell/pxa168_eth.c: In function =E2=80=98pxa16=
8_eth_probe=E2=80=99:
  drivers/net/ethernet/marvell/pxa168_eth.c:1605:2: error: implicit dec=
laration of function =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-func=
tion-declaration]
    iounmap(pep->base);
    ^

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 drivers/net/ethernet/marvell/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/etherne=
t/marvell/Kconfig
index bed8fbb..b3b72ad 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -64,7 +64,7 @@ config MVPP2
=20
 config PXA168_ETH
 	tristate "Marvell pxa168 ethernet support"
-	depends on CPU_PXA168 || ARCH_BERLIN || COMPILE_TEST
+	depends on (CPU_PXA168 || ARCH_BERLIN || COMPILE_TEST) && HAS_IOMEM
 	select PHYLIB
 	---help---
 	  This driver supports the pxa168 Ethernet ports.
--=20
1.9.3
