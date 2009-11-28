From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/32] sfc: Remove duplicate hardware structure definitions
Date: Sat, 28 Nov 2009 03:48:53 +0000
Message-ID: <1259380133.2811.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42597 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbZK1Dsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:48:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    6 +++---
 drivers/net/sfc/regs.h   |   12 ------------
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 5bbe842..9868e4a 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1463,8 +1463,8 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 	/* Determine interrupting queues, clear interrupt status
 	 * register and acknowledge the device interrupt.
 	 */
-	BUILD_BUG_ON(INT_EVQS_WIDTH > EFX_MAX_CHANNELS);
-	queues = EFX_OWORD_FIELD(*int_ker, INT_EVQS);
+	BUILD_BUG_ON(FSF_AZ_NET_IVEC_INT_Q_WIDTH > EFX_MAX_CHANNELS);
+	queues = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_INT_Q);
 	EFX_ZERO_OWORD(*int_ker);
 	wmb(); /* Ensure the vector is cleared before interrupt ack */
 	falcon_irq_ack_a1(efx);
@@ -1500,7 +1500,7 @@ static irqreturn_t falcon_msi_interrupt(int irq, void *dev_id)
 		  irq, raw_smp_processor_id(), EFX_OWORD_VAL(*int_ker));
 
 	/* Check to see if we have a serious error condition */
-	syserr = EFX_OWORD_FIELD(*int_ker, FATAL_INT);
+	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
 	if (unlikely(syserr))
 		return falcon_fatal_interrupt(efx);
 
diff --git a/drivers/net/sfc/regs.h b/drivers/net/sfc/regs.h
index f336d83..89d606f 100644
--- a/drivers/net/sfc/regs.h
+++ b/drivers/net/sfc/regs.h
@@ -3106,18 +3106,6 @@
 #define FALCON_STATS_NOT_DONE 0x00000000
 #define FALCON_STATS_DONE 0xffffffff
 
-/* Interrupt status register bits */
-#define FATAL_INT_LBN 64
-#define FATAL_INT_WIDTH 1
-#define INT_EVQS_LBN 40
-#define INT_EVQS_WIDTH 4
-#define INT_FLAG_LBN 32
-#define INT_FLAG_WIDTH 1
-#define EVQ_FIFO_HF_LBN 1
-#define EVQ_FIFO_HF_WIDTH 1
-#define EVQ_FIFO_AF_LBN 0
-#define EVQ_FIFO_AF_WIDTH 1
-
 /**************************************************************************
  *
  * Falcon non-volatile configuration

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

