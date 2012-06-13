From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 0/4] EEE for PAL and stmmac (v2)
Date: Wed, 13 Jun 2012 09:17:03 +0200
Message-ID: <1339571827-7162-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, rayagond@vayavyalabs.com,
	davem@davemloft.net, yuvalmin@broadcom.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:57058 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750793Ab2FMHRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 03:17:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add the EEE support in the stmmac device driver
restoring an old work I had done some months ago and not
completed in time.

I've tested all on ST STB with the IC+ 101G PHY device that has
this feature.

The initial EEE support for the stmmac has been written by Rayagond
but I have reworked all his code adding new parts and especially
performing tests on a real hardware. Thx Rayagond!

In these patches, we can see that the stmmac supports the EEE
only if the DMA HW capability register says that this
feature is actually available. In that case, the driver can enter
in the Tx LPI mode by using a timer as recommended by Synopsys.
Note that EEE is supported in new chip generations; in particular
I used the 3.61a.

At any rate, further information about how the driver treats the EEE
can be found in the stmmac.txt file (there is a patch for that).

Another patch is for Physical Abstraction Layer now able to
manage the MMD registers (clause 45); it also provides the ethtool
support to manage supported/advertisement/lp adv features.

Giuseppe Cavallaro (4):
  phy: add the EEE support and the way to access to the MMD registers.
  stmmac: do not use strict_strtoul but kstrtoul
  stmmac: update the driver Documentation and add EEE
  stmmac: add the Energy Efficient Ethernet support

 Documentation/networking/stmmac.txt                |   36 +++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   31 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   20 ++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  101 +++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   10 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   57 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  233 ++++++++++++++----
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +
 drivers/net/phy/phy.c                              |  261 ++++++++++++++++++++
 include/linux/mdio.h                               |   21 ++-
 include/linux/mii.h                                |    9 +
 include/linux/phy.h                                |    5 +
 14 files changed, 725 insertions(+), 66 deletions(-)

-- 
1.7.4.4
