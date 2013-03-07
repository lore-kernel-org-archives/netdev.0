From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/9] stmmac: update to March_2013 (adding PTP & RGMII/SGMII)
Date: Thu,  7 Mar 2013 11:50:10 +0100
Message-ID: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56593 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756737Ab3CGLrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches enhance the driver adding the PTP support
and the initial code for RGMII/SGMII/TBI/RTBI modes.

Thx goes to Rayagond that wrote and tested the PTP and
to Byungho for SGMII/RGMII.

Concerning the PTP, I have hacked/reviewed and tested many
part of these patches also verifying the back compatibility on
several HW and chips.

The PTP support is quite intrusive because it needs to support the extended
descriptors used for saving the HW timestamps.
These are available in new chip generations, only.
So we have actually found useful to use some Kconfig options to
surround PTP and extended descriptor support. This approach helped on
old platform (embeeded system) where PTP is not supported and where we
do not want to pay extra code and check in critical rx/tx paths.

Concerning the SGMII/RGMII we have already discussed about the support
in the net.dev Mailing list with Byungho where these patchs were partially
analysed.
So I have only ported them against the latest net-next (and on
top of PTP). I have added some missing things: e.g. some parts of the
ethtool for ANE. As we clarified with Byungho, we will add further
enhancements on top of these patches if needed.

I have also built all against ARM/SH/X68 platforms and no issues on
ST-Boxes (built-in & dyn modules).

Welcome feedback.
Peppe

Giuseppe Cavallaro (5):
  stmmac: support extend descriptors
  stmmac: add missing supported filters to get_ts_info
  stmmac: start adding pcs and rgmii core irq
  stmmac: initial support to manage pcs modes
  stmmac: update the Doc and Version (PTP+SGMII)

Rayagond Kokatanur (4):
  stmmac: add tx_skbuff_dma to save descriptors used by PTP
  stmmac: add IEEE 1588-2002 PTP support
  stmmac: add the support for PTP hw clock driver
  stmmac: add IEEE 1588-2008 PTP V2 support

 Documentation/networking/stmmac.txt                |   39 ++-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   40 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   30 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  106 ++++-
 drivers/net/ethernet/stmicro/stmmac/descs.h        |   47 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   40 ++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  104 ++++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    8 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    1 -
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  110 ++++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   40 ++-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   16 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   27 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  159 ++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_hwstamp.c   |  183 +++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  543 +++++++++++++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  209 ++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |   74 +++
 21 files changed, 1669 insertions(+), 115 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h

-- 
1.7.4.4
