From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 00/10] net: mvpp2: MAC/GoP configuration
Date: Tue, 22 Aug 2017 19:08:20 +0200
Message-ID: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38531 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdHVRIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:08:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is based on net-next (e2a7c34fb285).

I removed the GoP interrupt and PHY optional parts in this v2 to ease
the review process as the MAC/GoP initialization seemed to start less
discussions :)

This series now only aims at making the PPv2 driver less depending on
the firmware/bootloader initialization. Some patches cleanup some parts
as well, and add new interface descriptions in the dt.

The current implementation of the PPv2 driver relies on the
firmware/bootloader initialization to configure some parts, as the Group
of Ports (GoP) and the MACs (GMAC and/or XLG MAC --for 10G--).  The
drawback is the kernel must be configured to match exactly what the
bootloader configures which is not convenient and is an issue when using
boards having an Ethernet port and an SFP port wired to the same GoP
port, as no dynamic configuration can be done.

This series adds the GoP and GMAC/XLG MAC initializations so that the
PPV2 does not have to rely on a previous initialization. One part is
still missing from this series, and that would be the 'comphy' which
provides shared serdes PHYs and which must be configured as well for a
full kernel initialization to work. This comphy support will be part of
a following up series. (This series was also tested with this 'comphy'
support, as it's nearly ready).

@Dave: patches 9 and 10 should go through the mvebu tree. Thanks!

Since v1:
  - Split the previous series.
  - Rebased on net-next and reworked the series accordingly.
  - Added support for all RGMII variants.
  - Added a patch from Stefan Chulski improving / fixing 10G support.
  - Various small fixes.

Antoine Tenart (9):
  net: mvpp2: unify register definitions coding style
  net: mvpp2: fix the synchronization module bypass macro name
  net: mvpp2: move the mii configuration in the ndo_open path
  net: mvpp2: initialize the GMAC when using a port
  net: mvpp2: initialize the XLG MAC when using a port
  net: mvpp2: initialize the GoP
  Documentation/bindings: net: marvell-pp2: add the system controller
  arm64: dts: marvell: add a reference to the sysctrl syscon in the ppv2
    node
  arm64: dts: marvell: mcbin: enable more networking ports

Stefan Chulski (1):
  net: mvpp2: set maximum packet size for 10G ports

 .../devicetree/bindings/net/marvell-pp2.txt        |   1 +
 arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts  |  30 ++
 .../boot/dts/marvell/armada-cp110-master.dtsi      |   1 +
 .../arm64/boot/dts/marvell/armada-cp110-slave.dtsi |   1 +
 drivers/net/ethernet/marvell/mvpp2.c               | 432 +++++++++++++++++----
 5 files changed, 393 insertions(+), 72 deletions(-)

-- 
2.13.5
