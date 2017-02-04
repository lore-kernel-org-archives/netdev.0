From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 0/4] net: dsa: Support for pdata in dsa2
Date: Sat,  4 Feb 2017 12:57:07 -0800
Message-ID: <20170204205715.14708-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/Marvell
        Dove/MV78xx0/Orion SOC support),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36719 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750921AbdBDU7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 15:59:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is not exactly new, and was sent before, although back then, I did not
have an user of the pre-declared MDIO board information, but now we do. Note
that I have additional changes queued up to have b53 register platform data for
MIPS bcm47xx and bcm63xx.

Yes I know that we should have the Orion platforms eventually be converted to
Device Tree, but until that happens, I don't want any remaining users of the
old "dsa" platform device (hence the previous DTS submissions for ARM/mvebu)
and, there will be platforms out there that most likely won't never see DT
coming their way (BCM47xx is almost 100% sure, BCM63xx maybe not in a distant
future).

We would probably want the whole series to be merged via David Miller's tree
to simplify things.

Thanks!

Changes in v5:

- dropped changes to drivers/base/ because after more than a month, we cannot
  get any answer from Greg KH

Changes in v4:

- Changed device_find_class() to device_find_in_class_name()
- Added kerneldoc above device_find_in_class_name() to explain what it does
  and the calling convention regarding device reference counts
- Changed dev_to_net_device to device_to_net_device() added comments
  about what it does and the caller conventions regarding reference counts

Changes in v3:

- Tested EPROBE_DEFER from a mockup MDIO/DSA switch driver and everything
  is fine, once the driver finally probes we have access to platform data
  as expected

- added comment above dsa_port_is_valid() that port->name is mandatory
  for platform data cases

- added an extra check in dsa_parse_member() for a NULL pdata pointer

- fixed a bunch of checkpatch errors and warnings

Changes in v2:

- Rebased against latest net-next/master

- Moved dev_find_class() to device_find_class() into drivers/base/core.c

- Moved dev_to_net_device into net/core/dev.c

- Utilize dsa_chip_data directly instead of dsa_platform_data

- Augmented dsa_chip_data to be multi-CPU port ready

Changes from last submission (few months back):

- rebased against latest net-next

- do not introduce dsa2_platform_data which was overkill and was meant to
  allow us to do exaclty the same things with platform data and Device Tree
  we use the existing dsa_platform_data instead

- properly register MDIO devices when the MDIO bus is registered and associate
  platform_data with them

- add a change to the Orion platform code to demonstrate how this can be used

Thank you

Florian Fainelli (4):
  net: dsa: Rename and export dev_to_net_device()
  net: dsa: Add support for platform data
  net: phy: Allow pre-declaration of MDIO devices
  ARM: orion: Register DSA switch as a MDIO device

 arch/arm/mach-orion5x/common.c               |   2 +-
 arch/arm/mach-orion5x/common.h               |   4 +-
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |   7 +-
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |   7 +-
 arch/arm/mach-orion5x/rd88f6183ap-ge-setup.c |   7 +-
 arch/arm/mach-orion5x/wnr854t-setup.c        |   2 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |   7 +-
 arch/arm/plat-orion/common.c                 |  25 +++++--
 arch/arm/plat-orion/include/plat/common.h    |   4 +-
 drivers/net/phy/Makefile                     |   3 +-
 drivers/net/phy/mdio-boardinfo.c             |  86 ++++++++++++++++++++++
 drivers/net/phy/mdio-boardinfo.h             |  19 +++++
 drivers/net/phy/mdio_bus.c                   |   4 ++
 drivers/net/phy/mdio_device.c                |  11 +++
 include/linux/mdio.h                         |   3 +
 include/linux/mod_devicetable.h              |   1 +
 include/linux/phy.h                          |  19 +++++
 include/net/dsa.h                            |   7 ++
 net/dsa/dsa.c                                |   5 +-
 net/dsa/dsa2.c                               | 102 ++++++++++++++++++++++-----
 20 files changed, 268 insertions(+), 57 deletions(-)
 create mode 100644 drivers/net/phy/mdio-boardinfo.c
 create mode 100644 drivers/net/phy/mdio-boardinfo.h

-- 
2.9.3
