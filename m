From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 10/26] et131x: Eliminate RegistryDMA Cache
Date: Tue, 25 Aug 2009 15:59:12 +0100
Message-ID: <20090825145902.16176.32883.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:42601 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755296AbZHYPEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:04:34 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One writer, of a constant, one user .. it can go.

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/et1310_tx.c      |    2 +-
 drivers/staging/et131x/et131x_adapter.h |    1 -
 drivers/staging/et131x/et131x_config.c  |    1 -
 3 files changed, 1 insertions(+), 3 deletions(-)


diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131x/et1310_tx.c
index 0dbb824..8e8486a 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -315,7 +315,7 @@ void et131x_tx_dma_enable(struct et131x_adapter *etdev)
 		 */
 		csr.bits.sngl_epkt_mode = 1;
 		csr.bits.halt = 0;
-		csr.bits.cache_thrshld = etdev->RegistryDMACache;
+		csr.bits.cache_thrshld = PARM_DMA_CACHE_DEF;
 		writel(csr.value, &etdev->regs->txdma.csr.value);
 	}
 
diff --git a/drivers/staging/et131x/et131x_adapter.h b/drivers/staging/et131x/et131x_adapter.h
index 70a90b8..8e811af 100644
--- a/drivers/staging/et131x/et131x_adapter.h
+++ b/drivers/staging/et131x/et131x_adapter.h
@@ -271,7 +271,6 @@ struct et131x_adapter {
 	/* Validation helpers */
 	u8 RegistryPMWOL;
 	u8 RegistryNMIDisable;
-	u32 RegistryDMACache;
 	u32 RegistrySCGain;
 	u8 RegistryPhyLoopbk;	/* Enable Phy loopback */
 
diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/et131x/et131x_config.c
index 499cf75..628d6ad 100644
--- a/drivers/staging/et131x/et131x_config.c
+++ b/drivers/staging/et131x/et131x_config.c
@@ -265,7 +265,6 @@ void et131x_config_parse(struct et131x_adapter *etdev)
 	else
 		etdev->RegistryNMIDisable = PARM_NMI_DISABLE_DEF;
 
-	etdev->RegistryDMACache = PARM_DMA_CACHE_DEF;
 	etdev->RegistryPhyLoopbk = PARM_PHY_LOOPBK_DEF;
 
 	/* Set the MAC address to a default */

