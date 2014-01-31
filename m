From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 0/2] stmmac: Add extended multicast filtering for
Date: Fri, 31 Jan 2014 14:15:54 -0600
Message-ID: <1391199356-27226-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro@st.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, dinguyen@altera.com,
	rayagond@vayavyalabs.com, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:37340 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbaAaU0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 15:26:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add and correct multicast address filtering for the Altera 
Cyclone 5 SOC, and configuration parameters for multicast and perfect
filtering capabilities of a particular Synopsys EMAC. 

Filtering has been put through regression testing for the Altera C5 SOC, 
but not for other implementations. This implementation extends the filter
programming by examining the device characteristics and using either the
current set_multicast function or the new extended function that supports
all possible multicast filter configurations for the Synopsys EMAC. Review
comments are welcome. 

Thanks

Vince Bridgers (2):
  dts: Add bindings for multicast hash bins and perfect filter entries
  stmmac: add extended set multicast filter & devicetree options

 Documentation/devicetree/bindings/net/stmmac.txt   |    6 +
 drivers/net/ethernet/stmicro/stmmac/common.h       |   42 +++--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    5 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  161 +++++++++++++++++---
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   29 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   36 ++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   51 +++++++
 include/linux/stmmac.h                             |    2 +
 9 files changed, 267 insertions(+), 71 deletions(-)

-- 
1.7.9.5
