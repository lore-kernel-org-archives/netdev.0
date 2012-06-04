From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 3/4] stmmac: update driver's doc
Date: Mon,  4 Jun 2012 17:37:49 +0200
Message-ID: <1338824270-9222-4-git-send-email-peppe.cavallaro@st.com>
References: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:58985 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755368Ab2FDPiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:38:18 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4C11F114
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:13 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CC6F94641
	for <netdev@vger.kernel.org>; Mon,  4 Jun 2012 15:38:12 +0000 (GMT)
In-Reply-To: <1338824270-9222-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   44 +++++++++++++++++++---------------
 1 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index ab1e8d7..5cb9a19 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -10,8 +10,8 @@ Currently this network device driver is for all STM embedded MAC/GMAC
 (i.e. 7xxx/5xxx SoCs), SPEAr (arm), Loongson1B (mips) and XLINX XC2V3000
 FF1152AMT0221 D1215994A VIRTEX FPGA board.
 
-DWC Ether MAC 10/100/1000 Universal version 3.60a (and older) and DWC Ether MAC 10/100
-Universal version 4.0 have been used for developing this driver.
+DWC Ether MAC 10/100/1000 Universal version 3.60a (and older) and DWC Ether
+MAC 10/100 Universal version 4.0 have been used for developing this driver.
 
 This driver supports both the platform bus and PCI.
 
@@ -54,27 +54,27 @@ net_device structure enabling the scatter/gather feature.
 When one or more packets are received, an interrupt happens. The interrupts
 are not queued so the driver has to scan all the descriptors in the ring during
 the receive process.
-This is based on NAPI so the interrupt handler signals only if there is work to be
-done, and it exits.
+This is based on NAPI so the interrupt handler signals only if there is work
+to be done, and it exits.
 Then the poll method will be scheduled at some future point.
 The incoming packets are stored, by the DMA, in a list of pre-allocated socket
 buffers in order to avoid the memcpy (Zero-copy).
 
 4.3) Timer-Driver Interrupt
-Instead of having the device that asynchronously notifies the frame receptions, the
-driver configures a timer to generate an interrupt at regular intervals.
-Based on the granularity of the timer, the frames that are received by the device
-will experience different levels of latency. Some NICs have dedicated timer
-device to perform this task. STMMAC can use either the RTC device or the TMU
-channel 2  on STLinux platforms.
+Instead of having the device that asynchronously notifies the frame receptions,
+the driver configures a timer to generate an interrupt at regular intervals.
+Based on the granularity of the timer, the frames that are received by the
+device will experience different levels of latency. Some NICs have dedicated
+timer device to perform this task. STMMAC can use either the RTC device or the
+TMU channel 2  on STLinux platforms.
 The timers frequency can be passed to the driver as parameter; when change it,
 take care of both hardware capability and network stability/performance impact.
-Several performance tests on STM platforms showed this optimisation allows to spare
-the CPU while having the maximum throughput.
+Several performance tests on STM platforms showed this optimisation allows to
+spare the CPU while having the maximum throughput.
 
 4.4) WOL
-Wake up on Lan feature through Magic and Unicast frames are supported for the GMAC
-core.
+Wake up on Lan feature through Magic and Unicast frames are supported for the
+GMAC core.
 
 4.5) DMA descriptors
 Driver handles both normal and enhanced descriptors. The latter has been only
@@ -106,7 +106,8 @@ Several driver's information can be passed through the platform
 These are included in the include/linux/stmmac.h header file
 and detailed below as well:
 
- struct plat_stmmacenet_data {
+struct plat_stmmacenet_data {
+	char *phy_bus_name;
 	int bus_id;
 	int phy_addr;
 	int interface;
@@ -124,19 +125,24 @@ and detailed below as well:
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev);
 	void (*exit)(struct platform_device *pdev);
+	void *custom_cfg;
+	void *custom_data;
 	void *bsp_priv;
  };
 
 Where:
+ o phy_bus_name: phy bus name to attach to the stmmac.
  o bus_id: bus identifier.
  o phy_addr: the physical address can be passed from the platform.
 	    If it is set to -1 the driver will automatically
 	    detect it at run-time by probing all the 32 addresses.
  o interface: PHY device's interface.
  o mdio_bus_data: specific platform fields for the MDIO bus.
- o pbl: the Programmable Burst Length is maximum number of beats to
+ o dma_cfg: internal DMA parameters
+   o pbl: the Programmable Burst Length is maximum number of beats to
        be transferred in one DMA transaction.
        GMAC also enables the 4xPBL by default.
+   o fixed_burst/mixed_burst/burst_len
  o clk_csr: fixed CSR Clock range selection.
  o has_gmac: uses the GMAC core.
  o enh_desc: if sets the MAC will use the enhanced descriptor structure.
@@ -160,8 +166,9 @@ Where:
 	     this is sometime necessary on some platforms (e.g. ST boxes)
 	     where the HW needs to have set some PIO lines or system cfg
 	     registers.
- o custom_cfg: this is a custom configuration that can be passed while
-	      initialising the resources.
+ o custom_cfg/custom_data: this is a custom configuration that can be passed
+			   while initialising the resources.
+ o bsp_priv: another private poiter.
 
 For MDIO bus The we have:
 
@@ -180,7 +187,6 @@ Where:
  o irqs: list of IRQs, one per PHY.
  o probed_phy_irq: if irqs is NULL, use this for probed PHY.
 
-
 For DMA engine we have the following internal fields that should be
 tuned according to the HW capabilities.
 
-- 
1.7.4.4
