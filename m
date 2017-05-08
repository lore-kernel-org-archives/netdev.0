From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 0/4] stmmac: pci: Fix crash on Intel Galileo Gen2
Date: Mon,  8 May 2017 17:14:18 +0300
Message-ID: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Jan Kiszka <jan.kiszka@siemens.com>,
        netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50269 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754831AbdEHOO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 10:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to misconfiguration of PCI driver for Intel Quark the user will get
a kernel crash:

# udhcpc -i eth0
udhcpc: started, v1.26.2
stmmaceth 0000:00:14.6 eth0: device MAC address 98:4f:ee:05:ac:47
Generic PHY stmmac-a6:01: attached PHY driver [Generic PHY] (mii_bus:phy_addr=stmmac-a6:01, irq=-1)
stmmaceth 0000:00:14.6 eth0: IEEE 1588-2008 Advanced Timestamp supported
stmmaceth 0000:00:14.6 eth0: registered PTP clock
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready

udhcpc: sending discover

stmmaceth 0000:00:14.6 eth0: Link is Up - 100Mbps/Full - flow control off
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: stmmac_xmit+0xf1/0x1080

Fix this by adding necessary settings.

P.S. I split fix to three patches according to what each of them adds.

Andy Shevchenko (4):
  stmmac: pci: set default number of rx and tx queues
  stmmac: pci: TX and RX queue priority configuration
  stmmac: pci: RX queue routing configuration
  stmmac: pci: split out common_default_data() helper

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 41 +++++++++++-------------
 1 file changed, 18 insertions(+), 23 deletions(-)

-- 
2.11.0
