From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH kernel 1/4] sh_eth: Remove RX overflow log messages
Date: Tue, 27 Jan 2015 00:41:16 +0000
Message-ID: <1422319276.3524.15.camel@xylophone.i.decadent.org.uk>
References: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:49963 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbbA0AlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:41:15 -0500
In-Reply-To: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If RX traffic is overflowing the FIFO or DMA ring, logging every time
this happens just makes things worse.  These errors are visible in the
statistics anyway.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 2c4820a..3b49375 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1575,7 +1575,6 @@ ignore_link:
 		if (intr_status & EESR_RFRMER) {
 			/* Receive Frame Overflow int */
 			ndev->stats.rx_frame_errors++;
-			netif_err(mdp, rx_err, ndev, "Receive Abort\n");
 		}
 	}
 
@@ -1594,13 +1593,11 @@ ignore_link:
 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
 		ndev->stats.rx_over_errors++;
-		netif_err(mdp, rx_err, ndev, "Receive Descriptor Empty\n");
 	}
 
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
 		ndev->stats.rx_fifo_errors++;
-		netif_err(mdp, rx_err, ndev, "Receive FIFO Overflow\n");
 	}
 
 	if (!mdp->cd->no_ade && (intr_status & EESR_ADE)) {
-- 
1.7.10.4
