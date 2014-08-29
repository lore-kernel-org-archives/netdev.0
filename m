From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 0/5] ARM: Berlin: Ethernet support
Date: Fri, 29 Aug 2014 15:50:58 +0200
Message-ID: <1409320263-10295-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series introduce the Marvell Berlin Ethernet driver, allowing to
handle the fast Ethernet port. This driver is based on the mv643xx_eth
driver and reuse some of its functions. While I wanted to make these
functions common to the two drivers at first, I finally do think this
is not a great idea:
- Registers are very different.
- The mv643xx_eth supports up to 1000Mbps interfaces and performance
  issues may occur, whereas the mvberlin_eth is only for fast Ethernet.
- The mvberlin_eth driver uses a hash table to filter incoming packets.
- A few other differences.

I tried to stay close to the mv643xx_eth implementation, so that the
discussion is still open, but I still ended up with lots of tiny
differences that can be hard to manage for both cases. In the end I do
think having two separate drivers is a good choice.

That being said, I tested the Ethernet communication with ICMP pings,
netcat, tried to use some network related softwares (such as ssh). Here
is an iperf output:

 ------------------------------------------------------------
 Client connecting to 192.168.0.11, TCP port 5001
 TCP window size: 85.0 KByte (default)
 ------------------------------------------------------------
 [  3] local 192.168.0.20 port 44183 connected with 192.168.0.11 port 5001
 [ ID] Interval       Transfer     Bandwidth
 [  3]  0.0-10.0 sec   113 MBytes  94.8 Mbits/sec

Tests were done on a BG2Q DMP, and this series currently does not add
other device tree nodes than the ones for this board.

Thanks!

Antoine


Antoine Tenart (5):
  net: mvberlin_eth: add an Ethernet driver for Marvell Berlin
  Documentation: bindings: net: add the Marvell Berlin Ethernet
    controller
  Documentation: devicetree: net: mention Marvell Berlin
  ARM: dts: berlin: add ethernet and mdio nodes
  ARM: dts: berlin: enable the Ethernet port on the BG2Q DMP

 .../devicetree/bindings/net/marvell-berlin.txt     |   23 +
 .../devicetree/bindings/net/marvell-orion-mdio.txt |    6 +-
 arch/arm/boot/dts/berlin2q-marvell-dmp.dts         |   13 +
 arch/arm/boot/dts/berlin2q.dtsi                    |   19 +
 drivers/net/ethernet/marvell/Kconfig               |    9 +
 drivers/net/ethernet/marvell/Makefile              |    1 +
 drivers/net/ethernet/marvell/mvberlin_eth.c        | 2081 ++++++++++++++++++++
 7 files changed, 2149 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-berlin.txt
 create mode 100644 drivers/net/ethernet/marvell/mvberlin_eth.c

-- 
1.9.1
