From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 00/21] net: dsa: mv88e6xxx: turn into monolithic driver
Date: Mon,  9 May 2016 13:22:37 -0400
Message-ID: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset merges all mv88e6* drivers supported by the shared
mv88e6xxx code into a single mv88e6xxx DSA switch driver.

Some flags are added to describe the capabilities of a switch model,
such as the presence of a PPU, EEPROM, some old or new registers, etc.

First these flags are used to conditionally support the same set of
functions in every driver, then specific driver files are removed in
favor of the common mv88e6xxx driver.

Only the merge of driver specific setup code assumes a few differences.
If these differences such as frames priorities are really needed for
some models, they can easily be brought back in a future patch.

Some inconsistencies might show up, such as the need for
MV88E6XXX_FLAG_PPU and MV88E6XXX_FLAG_PPU_ACTIVE flags. But this
patchset does not aim to fix them yet. A future patch can do that if
they end up being unwanted.

The patchset has been tested on interconnected 88E6352 and 88E6185.

Changes v1 -> v2:
  - add missing MV88E6XXX_FLAG_EEPROM flag checks
  - remove a few remaining _ prefixes
  - remove MV88E6XXX_FLAG_CORE_TAG_TYPE which is a specific default

Changes RFC -> v1:
  - introduce flags in a separate patch
  - do not refactor anything yet
  - do not add new functions prefixed with _
  - drop packet discarding and mentioned tested platforms
  - factorize family flags
  - update text for NET_DSA_MV88E6XXX Kconfig entry

Vivien Didelot (21):
  net: dsa: mv88e6xxx: add flags to info
  net: dsa: mv88e6xxx: factorize PHY access with PPU
  net: dsa: mv88e6xxx: factorize PHY indirect access
  net: dsa: mv88e6xxx: factorize EEPROM access
  net: dsa: mv88e6xxx: factorize temperature access
  net: dsa: mv88e6xxx: factorize MAC address setting
  net: dsa: mv88e6xxx: factorize EEE access
  net: dsa: mv88e6131: add registers access
  net: dsa: mv88e6xxx: factorize bridge support
  net: dsa: mv88e6xxx: factorize VTU access
  net: dsa: mv88e6xxx: factorize ATU access
  net: dsa: mv88e6xxx: factorize switch reset
  net: dsa: mv88e6xxx: factorize global setup
  net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL setup
  net: dsa: mv88e6131: drop VLAN Ethertype setup
  net: dsa: mv88e6xxx: factorize GLOBAL_MONITOR_CONTROL setup
  net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL_2 setup
  net: dsa: mv88e6131: drop frames priorities setup
  net: dsa: mv88e6xxx: factorize switch setup
  net: dsa: mv88e6131: use EDSA tag protocol
  net: dsa: mv88e6xxx: factorize the switch driver

 arch/arm/configs/multi_v5_defconfig |   5 +-
 arch/arm/configs/mvebu_v7_defconfig |   2 +-
 arch/arm/configs/orion5x_defconfig  |   3 +-
 arch/tile/configs/tilegx_defconfig  |   3 +-
 arch/tile/configs/tilepro_defconfig |   3 +-
 drivers/net/dsa/Kconfig             |  45 +-
 drivers/net/dsa/Makefile            |  15 +-
 drivers/net/dsa/mv88e6123.c         | 130 -----
 drivers/net/dsa/mv88e6131.c         | 204 --------
 drivers/net/dsa/mv88e6171.c         | 151 ------
 drivers/net/dsa/mv88e6352.c         | 377 --------------
 drivers/net/dsa/mv88e6xxx.c         | 986 +++++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx.h         | 239 ++++++---
 13 files changed, 899 insertions(+), 1264 deletions(-)
 delete mode 100644 drivers/net/dsa/mv88e6123.c
 delete mode 100644 drivers/net/dsa/mv88e6131.c
 delete mode 100644 drivers/net/dsa/mv88e6171.c
 delete mode 100644 drivers/net/dsa/mv88e6352.c

-- 
2.8.2
