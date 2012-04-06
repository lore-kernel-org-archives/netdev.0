From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 0/4 (V3)] stmmac & EEE support
Date: Fri,  6 Apr 2012 11:29:14 +0200
Message-ID: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, rayagond@vayavyalabs.com,
	davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:36232 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754965Ab2DFJ3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 05:29:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add the EEE support in the stmmac device driver.
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
the EEE. There is a patch for the ethtool user space application;
I'm sending it too.

Another patch is for Physical Abstraction Layer now able to
manage the MMD registers (clause 45).
Maybe, I could directly add the EEE in the mdio driver.
I didn't that because I wanted to keep the stmmac able to access
to the phy registers through the Physical Abstraction Layer and
w/ having any links to the mdio.o.

Please Ben tells me if I well applied all your advice (when you
reviewed the ethtool/phy patches).

Regards
Peppe

Giuseppe CAVALLARO (1):
  stmmac: update the driver Documentation and add EEE

Giuseppe Cavallaro (3):
  net: ethtool: add the EEE support
  phy: add the EEE support and the way to access to the MMD regs
  stmmac: add the Energy Efficient Ethernet support

 Documentation/networking/stmmac.txt                |   36 ++++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   27 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   20 +++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  101 ++++++++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    6 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   48 ++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  156 +++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +
 drivers/net/phy/phy_device.c                       |  138 +++++++++++++++++
 include/linux/ethtool.h                            |    6 +
 include/linux/mdio.h                               |    6 +-
 include/linux/mii.h                                |   11 ++
 include/linux/phy.h                                |    3 +
 net/core/ethtool.c                                 |   32 ++++
 16 files changed, 572 insertions(+), 25 deletions(-)

-- 
1.7.4.4
