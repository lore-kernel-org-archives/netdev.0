From: Chris Brandt <chris.brandt@renesas.com>
Subject: [PATCH v2] sh_eth: remove unchecked interrupts
Date: Thu,  1 Dec 2016 09:06:42 -0500
Message-ID: <20161201140642.28583-1-chris.brandt@renesas.com>
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Chris Brandt <chris.brandt@renesas.com>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:56673 "EHLO
        relmlie3.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1759157AbcLAOHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 09:07:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
v2:
* switched from modifying eesr_err_check to modifying eesipr_value
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 05b0dc5..1a92de7 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -518,7 +518,7 @@ static struct sh_eth_cpu_data r7s72100_data = {
 
 	.ecsr_value	= ECSR_ICD,
 	.ecsipr_value	= ECSIPR_ICDIP,
-	.eesipr_value	= 0xff7f009f,
+	.eesipr_value	= 0xe77f009f,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
 	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
-- 
2.10.1
