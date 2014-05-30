From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] sh_eth: use RNC mode for R8A7790
Date: Fri, 30 May 2014 14:56:26 +0100
Message-ID: <1401458186-29985-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-kernel@codethink.co.uk,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damn@opensource.se,
	horms@verge.net.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:33449 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932162AbaE3N4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 09:56:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current behaviour of the sh_eth driver is not to use the RNC bit
for the receive ring. This means that every packet recieved is not only
generating an IRQ but it also stops the receive ring DMA as well until
the driver re-enables it after unloading the packet.

This means that a number of the following errors are generated due to
the receive packet FIFO overflowing due to nowhere to put packets:

	net eth0: Receive FIFO Overflow

Setting the RMCR_RNC configuration has so far been tested with an NFS
root filesystem and the driver has not failed yet. It is not yet known
why this is not set for R8A779x operation (Feedback on this issue or
other testing is welcome)

There are further test reports from Sergei Shtylov and others for
both the R8A7790 and R8A7791.

Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

---
Cc: nobuhiro.iwamatsu.yj@renesas.com
Cc: magnus.damn@opensource.se
Cc: horms@verge.net.au
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 6a9509c..1e3e5d2 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -468,6 +468,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
 	.eesipr_value	= 0x01ff009f,
+	.rmcr_value	= RMCR_RNC,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
-- 
2.0.0.rc2
