From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH V2 0/5] Add support for QCA IPQ806x Ethernet GMAC controller
Date: Wed, 27 May 2015 11:02:45 -0700
Message-ID: <1432749770-26133-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-clk@vger.kernel.org, netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	mturquette@linaro.org, sboyd@codeaurora.org,
	peppe.cavallaro@st.com, mathieu@codeaurora.org,
	agross@codeaurora.org, joshc@codeaurora.org,
	architt@codeaurora.org, georgi.djakov@linaro.org,
	wsa@the-dreams.de, rnayak@codeaurora.org, davem@davemloft.net,
	vbridger@opensource.altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45581 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbE0SD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:03:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support for the integrated Ethernet GMAC controller
on QCA IPQ806x SoC. This controller is based on a Gigabit Synopsys
DesignWare IP, already supported in the stmmac driver located in
drivers/net/ethernet/stmicro/stmmac.

This change is done as a follow-up to the following thread:
*http://www.spinics.net/lists/netdev/msg311265.html
While previous attempt was creating a new driver to drive this controller,
this new post leverages the existing stmmac driver by implementing the
SoC specific glue to it.

Aside from the pure stmmac glue layer, we have a couple of related
patches:
*IPQ806x NSS clock addition is cherry-picked and refreshed from the
 following thread: https://lkml.org/lkml/2014/8/6/390
*phy-handle and fixed-link support are also added in this change set so the
 driver can be fully functional on platforms using device-trees as well as
 ethernet switches.

V2:
 *Fix MODULE_LICENSE to "Dual BSD/GPL" as the dwmac-ipq806x.c is using
  ISC license.

Mathieu Olivari (4):
  stmmac: add phy-handle support to the platform layer
  stmmac: add fixed-link device-tree support
  stmmac: add ipq806x glue layer
  net: stmmac: ipq806x: document device tree bindings

Stephen Boyd (1):
  clk: qcom: Add support for NSS/GMAC clocks and resets

 .../devicetree/bindings/net/ipq806x-dwmac.txt      |  35 ++
 drivers/clk/qcom/gcc-ipq806x.c                     | 594 ++++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  14 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 .../net/ethernet/stmicro/stmmac/dwmac-ipq806x.c    | 365 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  30 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  18 +-
 include/dt-bindings/clock/qcom,gcc-ipq806x.h       |   2 +
 include/dt-bindings/reset/qcom,gcc-ipq806x.h       |  43 ++
 include/linux/stmmac.h                             |   1 +
 10 files changed, 1089 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ipq806x-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c

-- 
2.1.4
