From: Andreas Oetken <ennoerlangen@googlemail.com>
Subject: [PATCH 1/1] altera tse: Error-Bit on tx-avalon-stream always set.
Date: Tue, 21 Apr 2015 00:16:38 +0200
Message-ID: <1429568198-28064-1-git-send-email-ennoerlangen@gmail.com>
Cc: Andreas Oetken <ennoerlangen@gmail.com>
To: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38315 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbbDTWRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 18:17:13 -0400
Received: by wiun10 with SMTP id n10so906341wiu.1
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 15:17:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@gmail.com>

The Error-Bit on the avalon streaming interface of the
tx-dma-channel was always set. In SGMII configurations
this leads to error-symbols on the PCS and packet-rejection
on the receiver side (e.g. SGMII/1000Base-X connected switch).

This only applies to the tse-configuration with MSGDMA.

This issue was detected and fixed on a custom board with
a direct connection to a Marvell switch in SGMII-PHY-Mode.
(incl. custom patches for SGMII-PCS).

According to the datasheet if ff_tx_err (avalon-streaming)
is set it is forwarded to gm_tx_err. As a result the PCS
is forwarding the error by sending a "/V/"-caracter.

Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>
---
 drivers/net/ethernet/altera/altera_msgdmahw.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_msgdmahw.h b/drivers/net/ethernet/altera/altera_msgdmahw.h
index e335626..eba070f 100644
--- a/drivers/net/ethernet/altera/altera_msgdmahw.h
+++ b/drivers/net/ethernet/altera/altera_msgdmahw.h
@@ -72,7 +72,6 @@ struct msgdma_extended_desc {
 #define MSGDMA_DESC_CTL_TX_SINGLE	(MSGDMA_DESC_CTL_GEN_SOP |	\
 					 MSGDMA_DESC_CTL_GEN_EOP |	\
 					 MSGDMA_DESC_CTL_TR_COMP_IRQ |	\
-					 MSGDMA_DESC_CTL_TR_ERR_IRQ |	\
 					 MSGDMA_DESC_CTL_GO)
 
 #define MSGDMA_DESC_CTL_RX_SINGLE	(MSGDMA_DESC_CTL_END_ON_EOP |	\
-- 
2.1.4
