From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 0/3] net: stmmac: Improve mcast/ucast filter for snps
Date: Sun, 29 Jun 2014 20:35:07 -0500
Message-ID: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, davem@davemloft.net, vbridgers2013@gmail.com,
	vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:55602 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbaF3BjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:39:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds Synopsys specific bindings for the Synopsys EMAC
filter characteristics since those are implementation dependent. The
multicast and unicast filtering code was improved to handle different
configuration variations based on device tree settings. 

I verified the operation of the multicast and unicast filters through 
Synopsys support as requested during the V1 review, and tested the GMAC
configuration on an Altera Cyclone 5 SOC (which supports 256 multicast
bins and 128 Unicast addresses). The 10/100 variant of this driver
modification was not tested, although it was compile tested. I shared
the email thread results of the investigation through Synopsys with the
stmmac maintainer, Peppe. 

I look forward to receiving constructive comments and the eventual inclusion
of this patch series. 

All the best, 

Vince


Vince Bridgers (3):
  dts: Add bindings for multicast hash bins and perfect filter entries
  ARM: socfpga: Add socfpga Ethernet filter attributes entries
  net: stmmac: Improve mcast/ucast filter for all Synopsys EMAC
    Configurations

 Documentation/devicetree/bindings/net/stmmac.txt   |    6 +
 arch/arm/boot/dts/socfpga.dtsi                     |    4 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |   48 ++++----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  121 +++++++++++++-------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   27 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   38 +++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   52 +++++++++
 include/linux/stmmac.h                             |    2 +
 10 files changed, 213 insertions(+), 93 deletions(-)

-- 
1.7.9.5
