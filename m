From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 0/9] net: mvmdio: add xSMI support
Date: Wed,  7 Jun 2017 10:38:01 +0200
Message-ID: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37644 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdFGIjQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 04:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This series aims to add the xSMI support (also called xMDIO) to the
mvmdio driver. The xSMI interface complies with the IEEE 802.3 clause 45
and is used by 10GbE devices. On 7k and 8k (as of now), such an
interface is found and is used by Ethernet controllers.

Patches 1-3 are cosmetic cleanups.

Patches 4-6 are prerequisites to the xSMI support.

Patches 7-9 add the xSMI support to the mvmdio driver, and a node is
added both in the cp110 slave and master device trees.

This was tested on an Armada 8040 mcbin, as well as on both the
Armada 7040 DB and the Armada 8040 DB to ensure the SMI interface
was still working.

Thanks,
Antoine

Antoine Tenart (9):
  net: mvmdio: reorder headers alphabetically
  net: mvmdio: use tabs for defines
  net: mvmdio: use GENMASK for masks
  net: mvmdio: move the read valid check into its own function
  net: mvmdio: introduce an ops structure
  net: mvmdio: put the poll intervals in the private structure
  net: mvmdio: add xmdio support
  dt-bindings: orion-mdio: document the new xmdio compatible
  arm64: marvell: dts: add xmdio nodes for 7k/8k

 .../devicetree/bindings/net/marvell-orion-mdio.txt |   8 +-
 .../boot/dts/marvell/armada-cp110-master.dtsi      |   7 +
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |   7 +
 drivers/net/ethernet/marvell/Kconfig               |   6 +-
 drivers/net/ethernet/marvell/mvmdio.c              | 200 +++++++++++++++++----
 5 files changed, 184 insertions(+), 44 deletions(-)

-- 
2.9.4
