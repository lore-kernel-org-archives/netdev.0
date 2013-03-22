From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1 v2 net-next] net: fec: fix the build as module
Date: Fri, 22 Mar 2013 09:19:53 +0800
Message-ID: <1363915193-22179-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frank Li <Frank.Li@freescale.com>
To: <festevam@gmail.com>, <lznuaa@gmail.com>,
	<u.kleine-koenig@pengutronix.de>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:35904
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752344Ab3CVCa0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 22:30:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit ff43da86c69 (NET: FEC: dynamtic check DMA desc buff type) =
the
following build error happens when CONFIG_FEC=3Dm

ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefined=
!
ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undefine=
d!
ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/fec=
=2Eko] undefined!

rename fec.c to fec_main.c
Build fec.o and fec_ptp.o into one fec.ko

Reported-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
Change from V1 to V2
1. Use -M option to create patch

 drivers/net/ethernet/freescale/Makefile            |    3 ++-
 .../net/ethernet/freescale/{fec.c =3D> fec_main.c}   |    0
 2 files changed, 2 insertions(+), 1 deletions(-)
 rename drivers/net/ethernet/freescale/{fec.c =3D> fec_main.c} (100%)

diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethe=
rnet/freescale/Makefile
index b7d58fe..549ce13 100644
--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -2,7 +2,8 @@
 # Makefile for the Freescale network device drivers.
 #
=20
-obj-$(CONFIG_FEC) +=3D fec.o fec_ptp.o
+obj-$(CONFIG_FEC) +=3D fec.o
+fec-objs :=3Dfec_main.o fec_ptp.o
 obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx_phy.o
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec_main.c
similarity index 100%
rename from drivers/net/ethernet/freescale/fec.c
rename to drivers/net/ethernet/freescale/fec_main.c
--=20
1.7.1
