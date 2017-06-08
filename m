From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v2 0/8] net: mvmdio: add xSMI support
Date: Thu,  8 Jun 2017 11:26:45 +0200
Message-ID: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48845 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751481AbdFHKA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 06:00:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This series aims to add the xSMI support (also called xMDIO) to the
mvmdio driver. The xSMI interface complies with the IEEE 802.3 clause 45
and is used by 10GbE devices. On 7k and 8k (as of now), such an
interface is found and is used by Ethernet controllers.

Patches 1-3 are cosmetic cleanups.

Patches 4-6 are prerequisites to the xSMI support.

Patches 7-8 add the xSMI support to the mvmdio driver, and a node is
added both in the cp110 slave and master device trees.

This was tested on an Armada 8040 mcbin, as well as on both the
Armada 7040 DB and the Armada 8040 DB to ensure the SMI interface
was still working.

@Dave: patch 8 should go through the mvebu tree as asked by Gregory,
thanks!

Thanks,
Antoine

Since v1:
  - Instead of using the smi/xsmi helpers based on the compatible, now
    check if the MII_ADDR_C45 bit is set.
  - Removed the marvell,xmdio compatible addition.
  - Fixed the is_read_valid logic.
  - Updated to use static const variables for ops.
  - Added 3 Reviewed-by tags from Florian (I dropped another one as the
    patch changed in v2).

Antoine Tenart (8):
  net: mvmdio: reorder headers alphabetically
  net: mvmdio: use tabs for defines
  net: mvmdio: use GENMASK for masks
  net: mvmdio: move the read valid check into its own function
  net: mvmdio: introduce an ops structure
  net: mvmdio: put the poll intervals in the ops structure
  net: mvmdio: add xmdio support
  arm64: marvell: dts: add xmdio nodes for 7k/8k

 .../devicetree/bindings/net/marvell-orion-mdio.txt |   6 +-
 .../boot/dts/marvell/armada-cp110-master.dtsi      |   8 +
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |   8 +
 drivers/net/ethernet/marvell/Kconfig               |   6 +-
 drivers/net/ethernet/marvell/mvmdio.c              | 196 ++++++++++++++++-----
 5 files changed, 178 insertions(+), 46 deletions(-)

-- 
2.9.4
