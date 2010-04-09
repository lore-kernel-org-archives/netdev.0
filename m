From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] (net-2.6) stmmac update - Apr 2010
Date: Fri,  9 Apr 2010 12:24:15 +0200
Message-ID: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:54925 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757316Ab0DIKYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 06:24:30 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BC519138
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:24:28 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 505E41953
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:24:28 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
this is another subset of patches to make the driver more generic.

This patches splits the dma and core code for the mac 10/100 device
(as already done for the gmac) and reorganizes the descriptor
structures.
In the first version of the driver, the mac10/100 could only use
normal descriptors and the gmac could only use the enhanced ones.
This limit has been removed and this kind of information comes
from the platform.

Best Regards,
Giuseppe

Giuseppe Cavallaro (7):
  stmmac: split core and dma for the mac10/100
  stmmac: rework normal and enhanced descriptors
  stmmac: fix Transmit FIFO flush operation
  stmmac: new descriptor field for the driver's platform
  stmmac: get the descriptor structure from platform
  stmmac: fix vlan support setup
  stmmac: updated the drv module version

 drivers/net/stmmac/Makefile         |    2 +-
 drivers/net/stmmac/common.h         |   21 ++-
 drivers/net/stmmac/dwmac100.c       |  537 -----------------------------------
 drivers/net/stmmac/dwmac100.h       |    5 +
 drivers/net/stmmac/dwmac1000.h      |   12 -
 drivers/net/stmmac/dwmac1000_core.c |   27 +-
 drivers/net/stmmac/dwmac1000_dma.c  |  336 +---------------------
 drivers/net/stmmac/dwmac100_core.c  |  201 +++++++++++++
 drivers/net/stmmac/dwmac100_dma.c   |  138 +++++++++
 drivers/net/stmmac/dwmac_dma.h      |    1 +
 drivers/net/stmmac/dwmac_lib.c      |    7 +
 drivers/net/stmmac/enh_desc.c       |  342 ++++++++++++++++++++++
 drivers/net/stmmac/norm_desc.c      |  240 ++++++++++++++++
 drivers/net/stmmac/stmmac.h         |   10 +-
 drivers/net/stmmac/stmmac_main.c    |    7 +
 include/linux/stmmac.h              |    1 +
 16 files changed, 985 insertions(+), 902 deletions(-)
 delete mode 100644 drivers/net/stmmac/dwmac100.c
 create mode 100644 drivers/net/stmmac/dwmac100_core.c
 create mode 100644 drivers/net/stmmac/dwmac100_dma.c
 create mode 100644 drivers/net/stmmac/enh_desc.c
 create mode 100644 drivers/net/stmmac/norm_desc.c

