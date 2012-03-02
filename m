From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 0/6] stmmac: Driver Updates
Date: Fri, 2 Mar 2012 18:25:22 +0530
Message-ID: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear-devel@list.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:54687 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757136Ab2CBMzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 07:55:40 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 3B1B4D4
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:47:09 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id C385C75C
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:55:34 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set modifies the stmmac driver.
Following changes have been done in the patch set.
1. Explicitly have the option to pass checksum offload engine type
through the platform code. This is helpful for stmmac core prior to
revision 3.5
2. Pass the default value of clk_csr scaling through the platform code.
Define the scaling macros to be consistently used across driver and plat
code.
3. Update the stmmac driver to incorporate the CPU freq framework.
4. Update the DMA descriptor status checks for cores prior to rev-3.5.
5. Configure burst related DMA parameter for cores revision beyond
rev-3.6
6. Replace infinite loop in mdio read and write by timeouts

Deepak Sikri (6):
  stmmac: Define CSUM offload engine Types
  stmmac: Define MDC clock selection macros.
  stmmac: Add support for CPU freq notifiers.
  stmmac: Update stmmac descriptor checks for stmmac core prior to
    Rev-3.5.
  stmmac: configure burst related GMAC DMA parameters
  stmmac: Replace infinite loops by timeouts in mdio r/w

 drivers/net/ethernet/stmicro/stmmac/common.h       |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   14 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   17 ++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   10 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  138 +++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   30 ++++-
 include/linux/stmmac.h                             |   36 +++++
 9 files changed, 229 insertions(+), 21 deletions(-)
