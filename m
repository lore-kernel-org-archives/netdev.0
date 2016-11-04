From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 00/11] net: dsa: mv88e6xxx: refine port operations
Date: Fri,  4 Nov 2016 03:23:25 +0100
Message-ID: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell chips have one internal SMI device per port, containing a
set of registers used to configure a port's link, STP state, default
VLAN or addresses database, etc.

This patchset creates port files to implement the port operations as
described in datasheets, and extend the chip ops structure with them.

Patches 1 to 6 implement accessors for port's STP state, port based VLAN
map, default FID, default VID, and 802.1Q mode.

Patches 7 to 11 implement the port's MAC setup of link state, duplex
mode, RGMII delay and speed, all accessed through port's register 0x01.

The new port's MAC setup code is used to re-implement the adjust_link
code and correctly force the link down before changing any of the MAC
settings, as requested by the datasheets.

The port's MAC accessors use values compatible with struct phy_device
(e.g. DUPLEX_FULL) and extend them when needed (e.g. SPEED_MAX).

Changes in v2:

  - Strictly use new _UNFORCED values instead of re-using _UNKNOWN ones.

Vivien Didelot (11):
  net: dsa: mv88e6xxx: add port files
  net: dsa: mv88e6xxx: add port state setter
  net: dsa: mv88e6xxx: add port vlan map setter
  net: dsa: mv88e6xxx: add port FID accessors
  net: dsa: mv88e6xxx: add port PVID accessors
  net: dsa: mv88e6xxx: add port 802.1Q mode setter
  net: dsa: mv88e6xxx: add port link setter
  net: dsa: mv88e6xxx: add port duplex setter
  net: dsa: mv88e6xxx: add port's RGMII delay setter
  net: dsa: mv88e6xxx: add port's MAC speed setter
  net: dsa: mv88e6xxx: setup port's MAC

 drivers/net/dsa/mv88e6xxx/Makefile    |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 436 +++++++++--------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  49 +++-
 drivers/net/dsa/mv88e6xxx/port.c      | 497 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  52 ++++
 5 files changed, 727 insertions(+), 308 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/port.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/port.h

-- 
2.10.2
