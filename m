From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/8 (v2)] stmmac: update to March_2013 (ext desc, PTP, SGMII)
Date: Tue, 26 Mar 2013 15:43:04 +0100
Message-ID: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:51113 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758324Ab3CZOo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:44:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches enhance the driver adding the PTP support and the initial code
for RGMII/SGMII/TBI/RTBI modes.
Also this patches review the driver removing some Koption for selecting between
chain and ring modes. REally useful to validate the driver also at build time.
Before adding PTP, the extended descriptor support has been added because it
is mandatory to save HW timestamp in new dedicated descriptors. Also in this
case no Koption added.

Concerning the PTP, I have hacked/reviewed and tested many
part of these patches also verifying the back compatibility on
several HW and chips.

Concerning the SGMII/RGMII we have already discussed about the support
in the net.dev Mailing list with Byungho where these patchs were partially
analysed.
So I have only ported them against the latest net-next (and on
top of PTP). I have added some missing things: e.g. some parts of the
ethtool for ANE. As we clarified with Byungho, we will add further
enhancements on top of these patches if needed.

I have also built all against ARM/SH/X68 platforms and no issues on
ST-Boxes.

Thx goes to Rayagond that wrote and tested the PTP and to Byungho for SGMII.

V2: This Version 2 has the fixes discussed in the ML, for example:
    o completely remove the Koption... all the decisions are made at probe time
    o review the PTP patches and better organize them just in two patches
    o added all the fixes provided by Richard on PTP and CLK driver.

Giuseppe Cavallaro (5):
  stmmac: reorganize chain/ring modes removing Koptions
  stmmac: support extend descriptors
  stmmac: start adding pcs and rgmii core irq
  stmmac: initial support to manage pcs modes
  stmmac: update the Doc and Version (PTP+SGMII)

Rayagond Kokatanur (3):
  stmmac: add tx_skbuff_dma to save descriptors used by PTP
  stmmac: add IEEE PTPv1 and PTPv2 support.
  stmmac: add the support for PTP hw clock driver

 Documentation/networking/stmmac.txt                |   33 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   19 +-
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    8 +-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   90 ++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  122 ++-
 drivers/net/ethernet/stmicro/stmmac/descs.h        |   51 +-
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    |   44 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   40 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  104 ++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    8 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    4 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |  151 +++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   85 ++-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   38 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   23 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  156 +++-
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  148 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  994 ++++++++++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  215 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |   74 ++
 21 files changed, 2019 insertions(+), 391 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h

-- 
1.7.4.4
