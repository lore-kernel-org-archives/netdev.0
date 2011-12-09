From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH] flexcan: Acknowledge all interrupt sources in the IRQ handler
Date: Fri,  9 Dec 2011 14:47:34 +0100
Message-ID: <1323438454-6816-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Otherwise the handler will get stuck in an endless IRQ loop when an
interrupt condition occurs that is not being acked (e.g. TWRN)

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/can/flexcan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index e023379..ea8f04d 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -577,7 +577,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
=20
 	reg_iflag1 =3D flexcan_read(&regs->iflag1);
 	reg_esr =3D flexcan_read(&regs->esr);
-	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
+	flexcan_write(reg_esr, &regs->esr);	/* ACK all IRQs */
=20
 	/*
 	 * schedule NAPI in case of:
--=20
1.5.6.5

