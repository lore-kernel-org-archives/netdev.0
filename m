From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v6 00/10] ARM: Berlin: Ethernet support
Date: Tue, 30 Sep 2014 16:28:06 +0200
Message-ID: <1412087296-18475-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55650 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751567AbaI3O2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 10:28:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This series introduce support for the Ethernet controller on Berlin SoCs,
using the existing pxa168 Ethernet driver. In order to do this, DT
support is added to the driver alongside some other modifications and
fixes.

This has been tested on a Berlin BG2Q DMP board.

Changes since v5:
	- fixed the build when building the driver as a module

Changes since v4:
        - removed the phy-addr property and added a phy subnode
        - added COMPILE_TEST for the pxa168_eth driver

Changes since v3:
        - moved the addition of pxa168_eth_get_mac_address() to the patch
          using it first

Changes since v2:
        - reworked how the MAC address is configured
        - made the clock anonymous

Changes since v1:
        - removed custom Berlin Ethernet driver
        - used the pxa168 Ethernet driver instead
        - made modifications to the pxa168 driver (DT support, fixes)

Antoine Tenart (10):
  net: pxa168_eth: clean up
  net: pxa168_eth: add device tree support
  Documentation: bindings: net: add the Marvell PXA168 Ethernet
    controller
  net: pxa168_eth: fix Ethernet flow control status
  net: pxa168_eth: set the mac address on the Ethernet controller
  net: pxa168_eth: rework the MAC address setup
  net: pxa168_eth: allow Berlin SoCs to use the pxa168_eth driver
  net: pxa168_eth: allow to compile the pxa168_eth driver for tests
  ARM: dts: berlin: add the Ethernet node
  ARM: dts: berlin: enable the Ethernet port on the BG2Q DMP

 .../devicetree/bindings/net/marvell-pxa168.txt     |  36 ++++
 arch/arm/boot/dts/berlin2q-marvell-dmp.dts         |   4 +
 arch/arm/boot/dts/berlin2q.dtsi                    |  17 ++
 drivers/net/ethernet/marvell/Kconfig               |   2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          | 219 +++++++++++++--------
 5 files changed, 199 insertions(+), 79 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-pxa168.txt

-- 
1.9.1
