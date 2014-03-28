From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [RFC] sh_eth: use RNC mode for R8A7790
Date: Fri, 28 Mar 2014 16:46:25 +0000
Message-ID: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-sh@vger.kernel.org, magnus.damm@opensource.se,
	nobuhiro.iwamatsu.yj@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Ben Dooks <ben.dooks@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:36257 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751759AbaC1Qqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 12:46:32 -0400
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

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 942f1a9..7b02b70 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -467,6 +467,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
 	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
 	.eesipr_value	= 0x01ff009f,
+	.rmcr_value	= RMCR_RNC,
 
 	.tx_check	= EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO,
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
-- 
1.9.0
