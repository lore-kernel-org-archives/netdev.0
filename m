From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Remaining bits for basic support of LDP
Date: Sun, 1 Mar 2009 17:54:32 +0000
Message-ID: <20090301175432.GA24384@n2100.arm.linux.org.uk>
References: <20090210115615.GA9869@n2100.arm.linux.org.uk> <20090210210159.GK14200@atomide.com> <20090210213712.GB19041@n2100.arm.linux.org.uk> <20090210.171348.175525204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tony@atomide.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:58312 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931AbZCBQtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 11:49:40 -0500
Content-Disposition: inline
In-Reply-To: <20090210.171348.175525204.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2009 at 05:13:48PM -0800, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Tue, 10 Feb 2009 21:37:12 +0000
> 
> > On Tue, Feb 10, 2009 at 01:02:02PM -0800, Tony Lindgren wrote:
> > > Yeah, the smsc updates for omap might take a while longer to get going.
> > > So here's my ack for this smc911x patch:
> > > 
> > > Acked-by: Tony Lindgren <tony@atomide.com>
> > 
> > Thanks.
> 
> Russell if you formally resubmit this with proper changelog, signoffs,
> and acks I can merge it in quickly via the net-2.6 if you like.

Sorry for the delay.  Please find patch below.

OMAP: enable smc911x support for LDP platform

The following patch enables SMC911x support to work on the OMAP LDP
board.  Although the SMC911x driver will eventually be obsoleted, the
smsc911x patches are rather invasive for the -rc kernels.

Rather than risk destablising smsc911x, this simpler patch is preferred
to allow the network interface to work.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Acked-by: Tony Lindgren <tony@atomide.com>
---
 arch/arm/mach-omap2/board-ldp.c |    2 +-
 drivers/net/smc911x.h           |   12 ++++++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
index 61f7c36..d544965 100644
--- a/arch/arm/mach-omap2/board-ldp.c
+++ b/arch/arm/mach-omap2/board-ldp.c
@@ -81,7 +87,7 @@ static inline void __init ldp_init_smc911x(void)
 	}
 
 	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
-	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
+	ldp_smc911x_resources[0].end   = cs_mem_base + 0xff;
 	udelay(100);
 
 	eth_gpio = LDP_SMC911X_GPIO;
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 870b4c3..a45952e 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -42,6 +42,16 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+#elif defined(CONFIG_ARCH_OMAP34XX)
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+  #define SMC_MEM_RESERVED	1
+#elif defined(CONFIG_ARCH_OMAP24XX)
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+  #define SMC_MEM_RESERVED	1
 #else
 /*
  * Default configuration
@@ -675,6 +685,7 @@ smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
 #define CHIP_9116	0x0116
 #define CHIP_9117	0x0117
 #define CHIP_9118	0x0118
+#define CHIP_9211	0x9211
 #define CHIP_9215	0x115A
 #define CHIP_9217	0x117A
 #define CHIP_9218	0x118A
@@ -689,6 +700,7 @@ static const struct chip_id chip_ids[] =  {
 	{ CHIP_9116, "LAN9116" },
 	{ CHIP_9117, "LAN9117" },
 	{ CHIP_9118, "LAN9118" },
+	{ CHIP_9211, "LAN9211" },
 	{ CHIP_9215, "LAN9215" },
 	{ CHIP_9217, "LAN9217" },
 	{ CHIP_9218, "LAN9218" },


