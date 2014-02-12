From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 05/14] net: axienet: Service completion interrupts ASAP
Date: Wed, 12 Feb 2014 16:55:39 +0100
Message-ID: <cafb13f2ebe4bb996bafb91e405d8609454bb920.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2250-1392220593-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Peter Crosthwaite <peter.crosthwaite@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2250-1392220593-0001

From: Peter Crosthwaite <peter.crosthwaite@xilinx.com>

The packet completion interrupts for TX and RX should be serviced before
the packets are consumed. This ensures against the degenerate case when a
new completion interrupt is raised after the handler has exited but before
the interrupts are cleared. In this case its possible for the ISR to clear
an unhandled interrupt (leading to potential deadlock).

Signed-off-by: Peter Crosthwaite <peter.crosthwaite@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: Michal Simek <michal.simek@xilinx.com>
Tested-by: Jason Wu <huanyu@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 2e21ab2..3c24f97 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -809,6 +809,7 @@ static irqreturn_t axienet_tx_irq(int irq, void *_ndev)

 	status = axienet_dma_in32(lp, XAXIDMA_TX_SR_OFFSET);
 	if (status & (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_DELAY_MASK)) {
+		axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
 		axienet_start_xmit_done(lp->ndev);
 		goto out;
 	}
@@ -832,9 +833,9 @@ static irqreturn_t axienet_tx_irq(int irq, void *_ndev)
 		axienet_dma_out32(lp, XAXIDMA_RX_CR_OFFSET, cr);

 		tasklet_schedule(&lp->dma_err_tasklet);
+		axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
 	}
 out:
-	axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
 	return IRQ_HANDLED;
 }

@@ -857,6 +858,7 @@ static irqreturn_t axienet_rx_irq(int irq, void *_ndev)

 	status = axienet_dma_in32(lp, XAXIDMA_RX_SR_OFFSET);
 	if (status & (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_DELAY_MASK)) {
+		axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
 		axienet_recv(lp->ndev);
 		goto out;
 	}
@@ -880,9 +882,9 @@ static irqreturn_t axienet_rx_irq(int irq, void *_ndev)
 		axienet_dma_out32(lp, XAXIDMA_RX_CR_OFFSET, cr);

 		tasklet_schedule(&lp->dma_err_tasklet);
+		axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
 	}
 out:
-	axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
 	return IRQ_HANDLED;
 }

--
1.8.2.3


--=_mimegpg-monstr-desktop-2250-1392220593-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7mbEACgkQykllyylKDCHtlwCfTI9ClBX3i864IZnybUa4EjnJ
p1YAnA4BPJKHzVS7ND+Xehh/N41Vdtmk
=RDWK
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2250-1392220593-0001--
