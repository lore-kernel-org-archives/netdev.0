From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v5 0/2] stmmac: fix kernel crashes for jumbo frames
Date: Thu, 16 Jan 2014 14:10:24 -0600
Message-ID: <1389903026-12064-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro@st.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, dinguyen@altera.com,
	rayagond@vayavyalabs.com, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:57555 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaAPUPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 15:15:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v5:
* Simplify use notes for max-frame-size in stmmac.txt, in the
  devicetree patch. No change to the stmmac driver patch
  from v4.

v4:
* Address inconsistent comment with use, add comments about inconsistency
  of max-frame-size definition and use in the ePAPR v1.1 specification.

v3:
* change snps,max-frame-size to max-frame-size

v2:
* change snps,max-mtu to snps,max-frame-size

These patches address two kernel crashes seen when using jumbo frames on 
the Synopsys stmmac driver, and adds device tree configurability for the 
maximum mtu. The Synopsys emac fifo sizes can be configured when a logic
design is synthesized, but does not provide a way for a driver to query the
exact fifo size. 

The crashes seen were due to two issues. 

1) The dma buffer size was being set after the dma buffers were allocated.
This caused a crash when changing the mtu since it was possible the buffers
would subsequently be freed using an incorrect dma buffer size. This could
also cause kernel panics due to memory corruption since a large mtu size could
have been configured, but the dma buffers were not sized accordingly. 

2) Jumbo frames were being enabled by default, but the dma buffers were not
sized accordingly. This caused memory corruption in the context of certain
types of network traffic, leading to kernel panics. 

I've tested these changes using automated, reproducible testware. I can
demonstrate the panics described before the fixes and show that the fixes
address the problems described. 

Testing and improvements continue through the use of the mentioned automated
and reproducible testware. 

Vince Bridgers
Vince Bridgers (2):
  dts: Add a binding for Synopsys emac max-frame-size
  stmmac: Fix kernel crashes for jumbo frames

 Documentation/devicetree/bindings/net/stmmac.txt   |    5 ++++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    4 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    7 ++-----
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    7 ++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +++++++----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   13 +++++++++++++
 include/linux/stmmac.h                             |    1 +
 8 files changed, 37 insertions(+), 13 deletions(-)

-- 
1.7.9.5
