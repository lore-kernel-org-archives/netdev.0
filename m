From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH 11/13] Documentation: networking: update stmmac
Date: Fri, 25 Mar 2016 10:14:18 +0100
Message-ID: <1458897260-14104-12-git-send-email-alexandre.torgue@st.com>
References: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:60925 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751540AbcCYJPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 05:15:18 -0400
In-Reply-To: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update stmmac driver documentation according to new GMAC 4.x family.

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index d64a147..671fe3d 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -1,6 +1,6 @@
        STMicroelectronics 10/100/1000 Synopsys Ethernet driver
 
-Copyright (C) 2007-2014  STMicroelectronics Ltd
+Copyright (C) 2007-2015  STMicroelectronics Ltd
 Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 
 This is the driver for the MAC 10/100/1000 on-chip Ethernet controllers
@@ -138,6 +138,8 @@ struct plat_stmmacenet_data {
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
+	int has_gmac4;
+	bool tso_en;
 };
 
 Where:
@@ -181,6 +183,8 @@ Where:
 	     registers.  init/exit callbacks should not use or modify
 	     platform data.
  o bsp_priv: another private pointer.
+ o has_gmac4: uses GMAC4 core.
+ o tso_en: Enables TSO (TCP Segmentation Offload) feature.
 
 For MDIO bus The we have:
 
@@ -278,6 +282,13 @@ Please see the following document:
  o stmmac_ethtool.c: to implement the ethtool support;
  o stmmac.h: private driver structure;
  o common.h: common definitions and VFTs;
+ o mmc_core.c/mmc.h: Management MAC Counters;
+ o stmmac_hwtstamp.c: HW timestamp support for PTP;
+ o stmmac_ptp.c: PTP 1588 clock;
+ o dwmac-<XXX>.c: these are for the platform glue-logic file; e.g. dwmac-sti.c
+   for STMicroelectronics SoCs.
+
+- GMAC 3.x
  o descs.h: descriptor structure definitions;
  o dwmac1000_core.c: dwmac GiGa core functions;
  o dwmac1000_dma.c: dma functions for the GMAC chip;
@@ -289,11 +300,32 @@ Please see the following document:
  o enh_desc.c: functions for handling enhanced descriptors;
  o norm_desc.c: functions for handling normal descriptors;
  o chain_mode.c/ring_mode.c:: functions to manage RING/CHAINED modes;
- o mmc_core.c/mmc.h: Management MAC Counters;
- o stmmac_hwtstamp.c: HW timestamp support for PTP;
- o stmmac_ptp.c: PTP 1588 clock;
- o dwmac-<XXX>.c: these are for the platform glue-logic file; e.g. dwmac-sti.c
-   for STMicroelectronics SoCs.
+
+- GMAC4.x generation
+ o dwmac4_core.c: dwmac GMAC4.x core functions;
+ o dwmac4_desc.c: functions for handling GMAC4.x descriptors;
+ o dwmac4_descs.h: descriptor definitions;
+ o dwmac4_dma.c: dma functions for the GMAC4.x chip;
+ o dwmac4_dma.h: dma definitions for the GMAC4.x chip;
+ o dwmac4.h: core definitions for the GMAC4.x chip;
+ o dwmac4_lib.c: generic GMAC4.x functions;
+
+4.12) TSO support (GMAC4.x)
+
+TSO (Tcp Segmentation Offload) feature is supported by GMAC 4.x chip family.
+When a packet is sent through TCP protocol, the TCP stack ensures that
+the SKB provided to the low level driver (stmmac in our case) matches with
+the maximum frame len (IP header + TCP header + payload <= 1500 bytes (for
+MTU set to 1500)). It means that if an application using TCP want to send a
+packet which will have a length (after adding headers) > 1514 the packet
+will be split in several TCP packets: The data payload is split and headers
+(TCP/IP ..) are added. It is done by software.
+
+When TSO is enabled, the TCP stack doesn't care about the maximum frame
+length and provide SKB packet to stmmac as it is. The GMAC IP will have to
+perform the segmentation by it self to match with maximum frame length.
+
+This feature can be enabled in device tree through "snps,tso" entry.
 
 5) Debug Information
 
-- 
1.9.1
