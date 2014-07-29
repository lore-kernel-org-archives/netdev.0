From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v3 0/6] net: stmmac: Improve mcast/ucast filter for snps
Date: Tue, 29 Jul 2014 17:06:41 -0500
Message-ID: <1406671607-27368-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, davem@davemloft.net, vbridgers2013@gmail.com,
	vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45343 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaG2WK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 18:10:26 -0400
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
stmmac maintainer.

---
V3: Break up the patch into interface and functional change patches
    per review comments
V2: Confirm with Synopsys methods to determine number of Multicast bins
    and Unicast address filter entries per first round review comments.

Vince Bridgers (6):
  net: stmmac: Change MAC interface to support multiple filter
    configurations
  net: stmmac: Correct set_filter for multicast and unicast cases
  dts: Add bindings for multicast hash bins and perfect filter entries
  ARM: socfpga: Add socfpga Ethernet filter attributes entries
  net: stmmac: Support devicetree configs for mcast and ucast filter
    entries
  net: stmmac: squelch sparse warning with casts

 Documentation/devicetree/bindings/net/stmmac.txt   |    6 +
 arch/arm/boot/dts/socfpga.dtsi                     |    4 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |   47 ++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    3 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  131 ++++++++++++++------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   27 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   38 +++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   71 ++++++++++-
 include/linux/stmmac.h                             |    2 +
 10 files changed, 240 insertions(+), 95 deletions(-)

-- 
1.7.9.5
