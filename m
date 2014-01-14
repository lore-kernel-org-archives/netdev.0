From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v3 0/2] stmmac: fix kernel crashes for jumbo frames
Date: Tue, 14 Jan 2014 11:17:37 -0600
Message-ID: <1389719859-29071-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro@st.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, dinguyen@altera.com,
	rayagond@vayavyalabs.com, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:45921 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbaANRWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 12:22:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

 Documentation/devicetree/bindings/net/stmmac.txt   |    5 +++++
 drivers/net/ethernet/stmicro/stmmac/common.h       |    4 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    7 ++-----
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    7 ++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +++++++----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    5 +++++
 include/linux/stmmac.h                             |    1 +
 8 files changed, 30 insertions(+), 12 deletions(-)

-- 
1.7.9.5
