From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] stmmac: update the driver documentation
Date: Fri, 12 Nov 2010 12:37:32 +0100
Message-ID: <1289561852-22833-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:38371 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757205Ab0KLLho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 06:37:44 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5BFBC8A
	for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 11:37:38 +0000 (GMT)
Received: from mail1.ctn.st.com (mail1.ctn.st.com [164.130.116.128])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E21382615
	for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 11:37:37 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   48 +++++++++++++++++++++++++++--------
 1 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index 7ee770b..80a7a34 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -7,7 +7,7 @@ This is the driver for the MAC 10/100/1000 on-chip Ethernet controllers
 (Synopsys IP blocks); it has been fully tested on STLinux platforms.
 
 Currently this network device driver is for all STM embedded MAC/GMAC
-(7xxx SoCs).
+(7xxx SoCs). Other platforms start using it i.e. ARM SPEAr.
 
 DWC Ether MAC 10/100/1000 Universal version 3.41a and DWC Ether MAC 10/100
 Universal version 4.0 have been used for developing the first code
@@ -95,9 +95,14 @@ Several information came from the platform; please refer to the
 driver's Header file in include/linux directory.
 
 struct plat_stmmacenet_data {
-        int bus_id;
-        int pbl;
-        int has_gmac;
+	int bus_id;
+	int pbl;
+	int clk_csr;
+	int has_gmac;
+	int enh_desc;
+	int tx_coe;
+	int bugged_jumbo;
+	int pmt;
         void (*fix_mac_speed)(void *priv, unsigned int speed);
         void (*bus_setup)(unsigned long ioaddr);
 #ifdef CONFIG_STM_DRIVERS
@@ -114,6 +119,12 @@ Where:
   registers (on STM platforms);
 - has_gmac: GMAC core is on board (get it at run-time in the next step);
 - bus_id: bus identifier.
+- tx_coe: core is able to perform the tx csum in HW.
+- enh_desc: if sets the MAC will use the enhanced descriptor structure.
+- clk_csr: CSR Clock range selection.
+- bugged_jumbo: some HWs are not able to perform the csum in HW for
+  over-sized frames due to limited buffer sizes. Setting this
+  flag the csum will be done in SW on JUMBO frames.
 
 struct plat_stmmacphy_data {
         int bus_id;
@@ -131,13 +142,28 @@ Where:
 - interface: physical MII interface mode;
 - phy_reset: hook to reset HW function.
 
+SOURCES:
+- Kconfig
+- Makefile
+- stmmac_main.c: main network device driver;
+- stmmac_mdio.c: mdio functions;
+- stmmac_ethtool.c: ethtool support;
+- stmmac_timer.[ch]: timer code used for mitigating the driver dma interrupts
+  Only tested on ST40 platforms based.
+- stmmac.h: private driver structure;
+- common.h: common definitions and VFTs;
+- descs.h: descriptor structure definitions;
+- dwmac1000_core.c: GMAC core functions;
+- dwmac1000_dma.c:  dma functions for the GMAC chip;
+- dwmac1000.h: specific header file for the GMAC;
+- dwmac100_core: MAC 100 core and dma code;
+- dwmac100_dma.c: dma funtions for the MAC chip;
+- dwmac1000.h: specific header file for the MAC;
+- dwmac_lib.c: generic DMA functions shared among chips
+- enh_desc.c: functions for handling enhanced descriptors
+- norm_desc.c: functions for handling normal descriptors
+
 TODO:
-- Continue to make the driver more generic and suitable for other Synopsys
-  Ethernet controllers used on other architectures (i.e. ARM).
-- 10G controllers are not supported.
-- MAC uses Normal descriptors and GMAC uses enhanced ones.
-  This is a limit that should be reviewed. MAC could want to
-  use the enhanced structure.
-- Checksumming: Rx/Tx csum is done in HW in case of GMAC only.
+- XGMAC controller is not supported.
 - Review the timer optimisation code to use an embedded device that seems to be
   available in new chip generations.
-- 
1.5.5.6

