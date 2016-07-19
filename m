From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 00/12] net: dsa: mv88e6xxx: Global2 cleanup and STP
Date: Mon, 18 Jul 2016 20:45:28 -0400
Message-ID: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell switches registers are organized in distinct internal SMI
devices, such as PHY, Port, Global 1 or Global 2 registers sets.

Since not all chips support every registers sets or have slightly
differences in them (such as old 88E6060 or new 88E6390 likely to be
supported soon), make the setup code clearer now by removing a few
family checks and adding flags to describe the Global 2 registers map.

This patchset enables basic STP support and bridging on most chips when
getting rid of a few inconsistencies in chip descriptions (patch 1) and
add bridge Ageing Time support to DSA and the mv88e6xxx driver.

Changes v2 -> v3:
  - rename mv88e6xxx_update_write to mv88e6xxx_update
  - set fastest ageing time in use in the chip for multiple bridges,
    tested with a few printk

Changes v1 -> v2:
  - add a write helper for pointer-data Update registers
  - add ageing time support

Vivien Didelot (12):
  net: dsa: mv88e6xxx: remove basic function flags
  net: dsa: mv88e6xxx: split setup of Global 1 and 2
  net: dsa: mv88e6xxx: extract device mapping
  net: dsa: mv88e6xxx: extract trunk mapping
  net: dsa: mv88e6xxx: add cap for MGMT Enables bits
  net: dsa: mv88e6xxx: rework Switch MAC setter
  net: dsa: mv88e6xxx: add cap for PVT
  net: dsa: mv88e6xxx: add cap for Priority Override
  net: dsa: mv88e6xxx: add cap for IRL
  net: dsa: support switchdev ageing time attr
  net: dsa: mv88e6xxx: add G1 helper for ageing time
  net: dsa: mv88e6xxx: add support for DSA ageing time

 drivers/net/dsa/mv88e6xxx/chip.c      | 516 ++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 148 ++++++----
 include/net/dsa.h                     |   2 +
 net/dsa/slave.c                       |  41 +++
 4 files changed, 472 insertions(+), 235 deletions(-)

-- 
2.9.0
