From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCHv2 (net-next.git) 0/2] STMMAC: MDIO settings
Date: Wed, 16 Mar 2016 13:56:06 +0100
Message-ID: <1458132968-21206-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	<tomeu@tomeuvizoso.net>, <fabrice.gasnier@st.com>,
	<alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:8491 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934858AbcCPMvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 08:51:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are to fix the recent regressions raised
when test the stmmac on some platforms due to broken MDIO/PHY
management.

NOTE:

these are the same reviewed patches sent for net.git (version 4).
The patch #2 has been modified to solve a build problem on net-next;
inside the stmmac_init_phy where there is:

869         if (priv->plat->is_fixed_link)
870                 phydev->irq = PHY_IGNORE_INTERRUPT;

Note: still on-going for net-next a debug session to solve a recent
      regression when use normal descriptors.
      This will be sent in a new patch set.

V2: fix runtime problem due to NULL pointer.

Giuseppe Cavallaro (2):
  Revert "stmmac: Fix 'eth0: No PHY found' regression"
  stmmac: fix MDIO settings

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   16 +---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   10 +--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   91 ++++++++++++++------
 include/linux/stmmac.h                             |    1 -
 4 files changed, 72 insertions(+), 46 deletions(-)

-- 
1.7.4.4
