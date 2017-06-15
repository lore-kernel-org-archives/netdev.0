From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v5 00/11] net: mvmdio: add xMDIO xSMI support
Date: Thu, 15 Jun 2017 16:43:15 +0200
Message-ID: <20170615144326.24463-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34770 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752161AbdFOOoD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:44:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This series aims to add the xSMI support on the xMDIO bus to the
mvmdio driver. The xSMI interface complies with the IEEE 802.3 clause 45
and is used by 10GbE devices. On 7k and 8k (as of now), such an
interface is found and is used by Ethernet controllers.

Patches 1-4 and 9 are cosmetic cleanups.

Patches 5-7 are prerequisites to the xSMI support.

Patches 8 and 10-11 add the xSMI support to the mvmdio driver, and a
node is added both in the cp110 slave and master device trees.

This was tested on an Armada 8040 mcbin, as well as on both the
Armada 7040 DB and the Armada 8040 DB to ensure the SMI interface
was still working.

@Dave: patch 11 should go through the mvebu tree as asked by Gregory,
thanks!

Thanks,
Antoine

Since v4:
  - Reworded the documentation of the mvmdio bindings with Andrew's
    suggestion.
  - Added Reviewed-by tags from Florian.
  - Use the net-next tag now.

Since v3:
  - Added a patch from Russell King removing locks, as there is already
    per bus locking in the MDIO layer.
  - Russell suggested another approach to add the xSMI support, by having
    two different read/write functions. Reworked the series to take this
    into account. (This also lead to the removal of some patches, and the
    introduction of some others).

Since v2:
  - Brought back the marvell,xmdio compatible and updated the driver
    accordingly. The ops (smi, xsmi) are chosen based on the compatible.
  - Now return -EOPNOTSUPP when the MII_ADDR_C45 bit is wrongly set.
  - Mask dev_addr with GENMASK(4, 0).
  - Moved bit definitions under their register definition.
  - Fixed the write operation shift.
  - Added one space before the second parameter of GENMASK.

Since v1:
  - Instead of using the smi/xsmi helpers based on the compatible, now
    check if the MII_ADDR_C45 bit is set.
  - Removed the marvell,xmdio compatible addition.
  - Fixed the is_read_valid logic.
  - Updated to use static const variables for ops.
  - Added 3 Reviewed-by tags from Florian (I dropped another one as the
    patch changed in v2).

Antoine Tenart (10):
  net: mvmdio: reorder headers alphabetically
  net: mvmdio: use tabs for defines
  net: mvmdio: use GENMASK for masks
  net: mvmdio: introduce an ops structure
  net: mvmdio: put the poll intervals in the ops structure
  net: mvmdio: check the MII_ADDR_C45 bit is not set for smi operations
  net: mvmdio: add xmdio xsmi support
  net: mvmdio: simplify the smi read and write error paths
  dt-bindings: orion-mdio: document the new xmdio compatible
  arm64: marvell: dts: add xmdio nodes for 7k/8k

Russell King (1):
  net: mvmdio: remove duplicate locking

 .../devicetree/bindings/net/marvell-orion-mdio.txt |  10 +-
 .../boot/dts/marvell/armada-cp110-master.dtsi      |   8 +
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |   8 +
 drivers/net/ethernet/marvell/mvmdio.c              | 214 +++++++++++++++------
 4 files changed, 180 insertions(+), 60 deletions(-)

-- 
2.9.4
