From: Chris Brandt <chris.brandt@renesas.com>
Subject: [PATCH] sh_eth: add missing checks for status bits
Date: Wed, 30 Nov 2016 15:01:48 -0500
Message-ID: <20161130200148.9011-1-chris.brandt@renesas.com>
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Chris Brandt <chris.brandt@renesas.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When streaming a lot of data and the RZ can't keep up, some status bits
will get set that are not being checked or cleared which cause the
following messages and the Ethernet driver to stop working. This
patch fixes that issue.

irq 21: nobody cared (try booting with the "irqpoll" option)
handlers:
[<c036b71c>] sh_eth_interrupt
Disabling IRQ #21

Fixes: db893473d313a4ad ("sh_eth: Add support for r7s72100")
Signed-off-by: Chris Brandt <chris.brandt@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 05b0dc5..079f10e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -523,7 +523,7 @@ static struct sh_eth_cpu_data r7s72100_data = {
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
 			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
-			  EESR_TDE | EESR_ECI,
+			  EESR_TDE | EESR_ECI | EESR_TUC | EESR_ROC,
 	.fdr_value	= 0x0000070f,
 
 	.no_psr		= 1,
-- 
2.10.1
