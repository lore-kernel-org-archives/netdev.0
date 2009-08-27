From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 4/5] ucc_geth: Remove UGETH_MAGIC_PACKET Kconfig symbol and
 code
Date: Thu, 27 Aug 2009 21:35:56 +0400
Message-ID: <20090827173556.GD1580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Timur Tabi <timur@freescale.com>,
	Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:17556 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751732AbZH0Rfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 13:35:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes currently unused UGETH_MAGIC_PACKET Kconfig symbol
and code, i.e. magic_packet_detection_{enable,disable} functions.

The two functions each contain just two steps that we'll place into
suspend/resume code path under CONFIG_PM.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/Kconfig    |    4 ----
 drivers/net/ucc_geth.c |   32 --------------------------------
 2 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5f6509a..d171131 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2367,10 +2367,6 @@ config UCC_GETH
 	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
 	  which is available on some Freescale SOCs.
 
-config UGETH_MAGIC_PACKET
-	bool "Magic Packet detection support"
-	depends on UCC_GETH
-
 config UGETH_TX_ON_DEMAND
 	bool "Transmit on Demand support"
 	depends on UCC_GETH
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 488b591..d4e51ee 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -437,38 +437,6 @@ static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
 		     QE_CR_PROTOCOL_ETHERNET, 0);
 }
 
-#ifdef CONFIG_UGETH_MAGIC_PACKET
-static void magic_packet_detection_enable(struct ucc_geth_private *ugeth)
-{
-	struct ucc_fast_private *uccf;
-	struct ucc_geth __iomem *ug_regs;
-
-	uccf = ugeth->uccf;
-	ug_regs = ugeth->ug_regs;
-
-	/* Enable interrupts for magic packet detection */
-	setbits32(uccf->p_uccm, UCC_GETH_UCCE_MPD);
-
-	/* Enable magic packet detection */
-	setbits32(&ug_regs->maccfg2, MACCFG2_MPE);
-}
-
-static void magic_packet_detection_disable(struct ucc_geth_private *ugeth)
-{
-	struct ucc_fast_private *uccf;
-	struct ucc_geth __iomem *ug_regs;
-
-	uccf = ugeth->uccf;
-	ug_regs = ugeth->ug_regs;
-
-	/* Disable interrupts for magic packet detection */
-	clrbits32(uccf->p_uccm, UCC_GETH_UCCE_MPD);
-
-	/* Disable magic packet detection */
-	clrbits32(&ug_regs->maccfg2, MACCFG2_MPE);
-}
-#endif /* MAGIC_PACKET */
-
 static inline int compare_addr(u8 **addr1, u8 **addr2)
 {
 	return memcmp(addr1, addr2, ENET_NUM_OCTETS_PER_ADDRESS);
-- 
1.6.3.3

