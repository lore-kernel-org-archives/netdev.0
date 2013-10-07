From: Nguyen Hong Ky <nh-ky@jinso.co.jp>
Subject: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Mon,  7 Oct 2013 15:29:25 +0900
Message-ID: <1381127365-6521-2-git-send-email-nh-ky@jinso.co.jp>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
Cc: netdev@vger.kernel.org,
	Ryusuke Sakato <ryusuke.sakato.bx@renesas.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m119.secure.ne.jp ([158.199.161.240]:44579 "HELO
	m119.secure.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752352Ab3JGGgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 02:36:07 -0400
In-Reply-To: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch will fix RX packets errors when receiving big size
of data by set bit RNC = 1.

RNC - Receive Enable Control

0: Upon completion of reception of one frame, the E-DMAC writes
the receive status to the descriptor and clears the RR bit in
EDRRR to 0.

1: Upon completion of reception of one frame, the E-DMAC writes
(writes back) the receive status to the descriptor. In addition,
the E-DMAC reads the next descriptor and prepares for reception
of the next frame.

In addition, for get more stable when receiving packets, I set
maximum size for the transmit/receive FIFO and inserts padding
in receive data.

Signed-off-by: Nguyen Hong Ky <nh-ky@jinso.co.jp>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index a753928..11d34f0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -649,12 +649,16 @@ static struct sh_eth_cpu_data r8a7740_data = {
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
 			  EESR_TDE | EESR_ECI,
+	.fdr_value	= 0x0000070f,
+	.rmcr_value	= 0x00000001,
 
 	.apr		= 1,
 	.mpr		= 1,
 	.tpauser	= 1,
 	.bculr		= 1,
 	.hw_swap	= 1,
+	.rpadir		= 1,
+	.rpadir_value   = 2 << 16,
 	.no_trimd	= 1,
 	.no_ade		= 1,
 	.tsu		= 1,
-- 
1.7.5.4
