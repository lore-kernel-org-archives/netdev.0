From: Bob Liu <lliubbo@gmail.com>
Subject: [RESEND][PATCH] drivers: net: irda: bfin_sir: fix compile error
Date: Tue, 7 Aug 2012 10:08:36 +0800
Message-ID: <1344305316-23916-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <samuel@sortiz.org>, <rmk+kernel@arm.linux.org.uk>,
	<gregkh@linuxfoundation.org>, <kuninori.morimoto.gx@renesas.com>,
	<linux-kernel@vger.kernel.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	<netdev@vger.kernel.org>, Sonic Zhang <sonic.zhang@analog.com>,
	Bob Liu <lliubbo@gmail.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sonic Zhang <sonic.zhang@analog.com>

Bit IREN is replaced by UMOD_IRDA and UMOD_MASK since blackfin 60x added, but
this driver didn't update which will cause bfin_sir build error:

drivers/net/irda/bfin_sir.c:161:9: error: 'IREN' undeclared (first use in this
function)
drivers/net/irda/bfin_sir.c:435:18: error: 'IREN' undeclared (first use in
this function)
drivers/net/irda/bfin_sir.c:521:11: error: 'IREN' undeclared (first use in
this function)

This patch fix it.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/bfin_sir.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index a561ae4..c6a0299 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -158,7 +158,7 @@ static int bfin_sir_set_speed(struct bfin_sir_port *port, int speed)
 	/* If not add the 'RPOLC', we can't catch the receive interrupt.
 	 * It's related with the HW layout and the IR transiver.
 	 */
-	val |= IREN | RPOLC;
+	val |= UMOD_IRDA | RPOLC;
 	UART_PUT_GCTL(port, val);
 	return ret;
 }
@@ -432,7 +432,7 @@ static void bfin_sir_shutdown(struct bfin_sir_port *port, struct net_device *dev
 	bfin_sir_stop_rx(port);
 
 	val = UART_GET_GCTL(port);
-	val &= ~(UCEN | IREN | RPOLC);
+	val &= ~(UCEN | UMOD_MASK | RPOLC);
 	UART_PUT_GCTL(port, val);
 
 #ifdef CONFIG_SIR_BFIN_DMA
@@ -518,10 +518,10 @@ static void bfin_sir_send_work(struct work_struct *work)
 	 * reset all the UART.
 	 */
 	val = UART_GET_GCTL(port);
-	val &= ~(IREN | RPOLC);
+	val &= ~(UMOD_MASK | RPOLC);
 	UART_PUT_GCTL(port, val);
 	SSYNC();
-	val |= IREN | RPOLC;
+	val |= UMOD_IRDA | RPOLC;
 	UART_PUT_GCTL(port, val);
 	SSYNC();
 	/* bfin_sir_set_speed(port, self->speed); */
-- 
1.7.9.5
