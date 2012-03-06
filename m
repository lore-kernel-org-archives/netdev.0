From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 3/4] stmmac: update the driver Documentation and add EEE
Date: Tue,  6 Mar 2012 09:28:13 +0100
Message-ID: <1331022494-12891-4-git-send-email-peppe.cavallaro@st.com>
References: <4F4E4D4B.3040909@st.com>
 <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:59983 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758649Ab2CFI26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 03:28:58 -0500
In-Reply-To: <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the stmmac's documentation adding
some missing files in the secstion to describe the
driver's structure. Also the patch adds a new section
for the EEE support.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |   36 +++++++++++++++++++++++++++++-----
 1 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index d0aeead..cd38f6e 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -230,9 +230,11 @@ reset procedure etc).
  o Makefile
  o stmmac_main.c: main network device driver;
  o stmmac_mdio.c: mdio functions;
+ o stmmac_pci: PCI driver;
+ o stmmac_platform.c: platform driver
  o stmmac_ethtool.c: ethtool support;
  o stmmac_timer.[ch]: timer code used for mitigating the driver dma interrupts
-		      Only tested on ST40 platforms based.
+		      (only tested on ST40 platforms based);
  o stmmac.h: private driver structure;
  o common.h: common definitions and VFTs;
  o descs.h: descriptor structure definitions;
@@ -242,9 +244,11 @@ reset procedure etc).
  o dwmac100_core: MAC 100 core and dma code;
  o dwmac100_dma.c: dma funtions for the MAC chip;
  o dwmac1000.h: specific header file for the MAC;
- o dwmac_lib.c: generic DMA functions shared among chips
- o enh_desc.c: functions for handling enhanced descriptors
- o norm_desc.c: functions for handling normal descriptors
+ o dwmac_lib.c: generic DMA functions shared among chips;
+ o enh_desc.c: functions for handling enhanced descriptors;
+ o norm_desc.c: functions for handling normal descriptors;
+ o chain_mode.c/ring_mode.c:: functions to manage RING/CHAINED modes;
+ o mmc_core.c/mmc.h: Management MAC Counters;
 
 5) Debug Information
 
@@ -277,7 +281,27 @@ All these are only useful during the developing stage
 and should never enabled inside the code for general usage.
 In fact, these can generate an huge amount of debug messages.
 
-6) TODO:
+6) Energy Efficient Ethernet
+
+Energy Efficient Ethernet(EEE) enables IEEE 802.3 MAC sublayer along
+with a family of Physical layer to operate in the Low power Idle(LPI)
+mode. The EEE mode supports the IEEE 802.3 MAC operation at 100Mbps,
+1000Mbps & 10Gbps.
+
+The LPI mode allows power saving by switching off parts of the
+communication device functionality when there is no data to be
+transmitted & received. The system on both the side of the link can
+disable some functionalities & save power during the period of low-link
+utilization. The MAC controls whether the system should enter or exit
+the LPI mode & communicate this to PHY.
+
+As soon as the interface is opened, the driver verifies if the EEE can
+be supported. This is done by looking at both the DMA HW capability
+register and the PHY devices MCD registers.
+To enter in Tx LPI mode the driver needs to have a software timer
+that enable and disable the LPI mode when there is nothing to be
+transmitted.
+
+7) TODO:
  o XGMAC is not supported.
- o Add the EEE - Energy Efficient Ethernet
  o Add the PTP - precision time protocol
-- 
1.7.4.4
