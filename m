From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 0/4] stmmac: add the EEE support
Date: Tue,  6 Mar 2012 09:28:10 +0100
Message-ID: <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
References: <4F4E4D4B.3040909@st.com>
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:55576 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758674Ab2CFI2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 03:28:51 -0500
In-Reply-To: <4F4E4D4B.3040909@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add the EEE support in the stmmac device driver;
Patches have been built against net-next.git repository.

Please discard the previous ones sent for net.git.

I've tested it on ST STB with the IC+ 101G PHY device that has
this feature.
Initially the EEE for the stmmac has been written by Rayagond
but I reworked all his code adding new parts and especially
performing tests on a real hardware. Thx Rayagond!

In these patches, we can see that the stmmac supports the EEE
only if the DMA HW capability register says that this
feature is actually available. In that case, the driver can enter
in the Tx LPI mode by using a timer as recommended by Synopsys.
Note that EEE is supported in new chip generations; in particular
I used the 3.61a.

At any rate, further information about how the driver treats the EEE
can be found in the stmmac.txt file (there is a patch for that).

These patches also add a new option for ethtool to enable/disable
the EEE.
I've already sent the patch for the ethtool user space application.

Another patch is for Physical Abstraction Layer now able to
manage the MMD registers (clause 45).
Maybe, I could directly add the EEE in the mdio driver.
I didn't that because I wanted to keep the stmmac able to access
to the phy registers through the Physical Abstraction Layer and
w/ having any links to the mdio.o.

Welcome review and advice.
Regards
Peppe

Giuseppe Cavallaro (4):
  phy: add the EEE support and the way to access to the MMD regs
  net: ethtool: add the EEE support
  stmmac: update the driver Documentation and add EEE
  stmmac: add the Energy Efficient Ethernet support.

 Documentation/networking/stmmac.txt                |   36 ++++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   27 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   20 +++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  101 ++++++++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    7 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   46 ++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  157 +++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +
 drivers/net/phy/phy_device.c                       |  136 +++++++++++++++++
 include/linux/ethtool.h                            |    7 +
 include/linux/mdio.h                               |    5 +
 include/linux/mii.h                                |   11 ++
 include/linux/phy.h                                |    3 +
 net/core/ethtool.c                                 |   32 ++++
 16 files changed, 571 insertions(+), 24 deletions(-)

-- 
1.7.4.4
