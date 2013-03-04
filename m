From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1] net: fec: fix build error in no MXC platform
Date: Mon, 4 Mar 2013 14:52:38 +0800
Message-ID: <1362379958-12972-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:38410
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753251Ab3CDH5d convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Mar 2013 02:57:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

build error cause by
Commit ff43da86c69d76a726ffe7d1666148960dc1d108
("NET: FEC: dynamtic check DMA desc buff type")

drivers/net/ethernet/freescale/fec.c: In function =E2=80=98fec_enet_get=
_nextdesc=E2=80=99:
drivers/net/ethernet/freescale/fec.c:215:18: error: invalid use of unde=
fined type =E2=80=98struct bufdesc_ex=E2=80=99
drivers/net/ethernet/freescale/fec.c: In function =E2=80=98fec_enet_get=
_prevdesc=E2=80=99:
drivers/net/ethernet/freescale/fec.c:224:18: error: invalid use of unde=
fined type =E2=80=98struct bufdesc_ex=E2=80=99
drivers/net/ethernet/freescale/fec.c: In function =E2=80=98fec_enet_sta=
rt_xmit=E2=80=99:
drivers/net/ethernet/freescale/fec.c:286:37: error: arithmetic on point=
er to an incomplete type
drivers/net/ethernet/freescale/fec.c:287:13: error: arithmetic on point=
er to an incomplete type
drivers/net/ethernet/freescale/fec.c:324:7: error: dereferencing pointe=
r to incomplete type etc....

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 01579b8..a53150c 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -97,6 +97,13 @@ struct bufdesc {
 	unsigned short cbd_sc;	/* Control and status info */
 	unsigned long cbd_bufaddr;	/* Buffer address */
 };
+#else
+struct bufdesc {
+	unsigned short	cbd_sc;			/* Control and status info */
+	unsigned short	cbd_datlen;		/* Data length */
+	unsigned long	cbd_bufaddr;		/* Buffer address */
+};
+#endif
=20
 struct bufdesc_ex {
 	struct bufdesc desc;
@@ -107,14 +114,6 @@ struct bufdesc_ex {
 	unsigned short res0[4];
 };
=20
-#else
-struct bufdesc {
-	unsigned short	cbd_sc;			/* Control and status info */
-	unsigned short	cbd_datlen;		/* Data length */
-	unsigned long	cbd_bufaddr;		/* Buffer address */
-};
-#endif
-
 /*
  *	The following definitions courtesy of commproc.h, which where
  *	Copyright (c) 1997 Dan Malek (dmalek@jlc.net).
--=20
1.7.1
