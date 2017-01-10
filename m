From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/8] net: dsa: Support for pdata in dsa2
Date: Tue, 10 Jan 2017 12:12:27 -0800
Message-ID: <20170110201235.21771-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/Marvell
        Dove/MV78xx0/Orion SOC support),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Changes from last submission (few months back):

- rebased against latest net-next

- do not introduce dsa2_platform_data which was overkill and was meant to
  allow us to do exaclty the same things with platform data and Device Tree
  we use the existing dsa_platform_data instead

- properly register MDIO devices when the MDIO bus is registered and associate
  platform_data with them

- add a change to the Orion platform code to demonstrate how this can be used

Thank you

Florian Fainelli (8):
  net: dsa: Pass device pointer to dsa_register_switch
  net: dsa: Make most functions take a dsa_port argument
  net: dsa: Suffix function manipulating device_node with _dn
  net: dsa: Move ports assignment closer to error checking
  net: dsa: Export dev_to_net_device()
  net: dsa: Add support for platform data
  net: phy: Allow pre-declaration of MDIO devices
  ARM: orion: Register DSA switch as a MDIO device

 arch/arm/plat-orion/common.c     |  19 ++++-
 drivers/net/dsa/b53/b53_common.c |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |   8 +-
 drivers/net/dsa/qca8k.c          |   2 +-
 drivers/net/phy/Makefile         |   3 +-
 drivers/net/phy/mdio-boardinfo.c |  86 ++++++++++++++++++++
 drivers/net/phy/mdio-boardinfo.h |  19 +++++
 drivers/net/phy/mdio_bus.c       |   5 ++
 drivers/net/phy/mdio_device.c    |  11 +++
 include/linux/mdio.h             |   3 +
 include/linux/mod_devicetable.h  |   1 +
 include/linux/phy.h              |  19 +++++
 include/net/dsa.h                |   4 +-
 net/dsa/dsa.c                    |  18 +++--
 net/dsa/dsa2.c                   | 169 +++++++++++++++++++++++++++------------
 net/dsa/dsa_priv.h               |   4 +-
 16 files changed, 301 insertions(+), 72 deletions(-)
 create mode 100644 drivers/net/phy/mdio-boardinfo.c
 create mode 100644 drivers/net/phy/mdio-boardinfo.h

-- 
2.9.3
