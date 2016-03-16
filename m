From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv4 (net.git) 0/2] STMMAC: fix MDIO settings
Date: Wed, 16 Mar 2016 10:38:47 +0100
Message-ID: <1458121129-18818-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:1825 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964779AbcCPJdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:33:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are to fix the recent regressions raised
when test the stmmac on some platforms due to broken MDIO/PHY
management.

=========================================================================

V2: to use is_pseudo_fixed_link
V3: to enforce the driver to support other configurations
  The mdio bus will be allocated in case of a phy transceiver is on board;
  it will be NULL if the fixed-link is configured.
  If there is the "snps,dwmac-mdio" sub-node the mdio will be allocated
  in any case (for DSA, mdio must be registered even if fixed-link).
  The table below sums the supported configurations:
 	-------------------------------
 	snps,phy-addr	|     Y
 	-------------------------------
 	phy-handle	|     Y
 	-------------------------------
 	fixed-link	|     N
 	-------------------------------
 	snps,dwmac-mdio	|
 	  even if	|     Y
 	fixed-link	|
 	-------------------------------

V4: fixed some typo and the return value of the new stmmac_dt_phy
    function.

=========================================================================

Giuseppe Cavallaro (2):
  Revert "stmmac: Fix 'eth0: No PHY found' regression"
  stmmac: fix MDIO settings

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   10 +--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   91 ++++++++++++++------
 include/linux/stmmac.h                             |    1 -
 4 files changed, 70 insertions(+), 43 deletions(-)

-- 
1.7.4.4
