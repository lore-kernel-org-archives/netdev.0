From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 00/10] net: dsa: mv88e6xxx: Global (1) cosmetics
Date: Thu, 29 Sep 2016 12:21:52 -0400
Message-ID: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Global (1) internal SMI device of Marvell switches is a set of
registers providing support to different units for MAC addresses (ATU),
VLANs (VTU), PHY polling (PPU), etc.

Chips (like 88E6060) may use a different address for it, or have
subtleties in the units (e.g. different number of databases, changing
how registers must be accessed), making it hard to maintain properly.

This patchset is a first step to polish the Global (1) support, with no
functional changes though. Here's basically what it does:

  - add helpers to access Global1 registers (same for Global2)
  - remove a few family checks (VTU/STU FID registers)
  - s/mv88e6xxx_vtu_stu_entry/mv88e6xxx_vtu_entry/
  - add a per-chip mv88e6xxx_ops structure of function pointers:

  struct mv88e6xxx_ops {
        int (*get_eeprom)(struct mv88e6xxx_chip *chip,
                          struct ethtool_eeprom *eeprom, u8 *data);
        int (*set_eeprom)(struct mv88e6xxx_chip *chip,
                          struct ethtool_eeprom *eeprom, u8 *data);

        int (*set_switch_mac)(struct mv88e6xxx_chip *chip, u8 *addr);

        int (*phy_read)(struct mv88e6xxx_chip *chip, int addr, int reg,
                        u16 *val);
        int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
                         u16 val);
  };

Future patchsets will add ATU/VTU ops, software reset, etc.

Vivien Didelot (10):
  net: dsa: mv88e6xxx: add global1 helpers
  net: dsa: mv88e6xxx: abstract REG_GLOBAL2
  net: dsa: mv88e6xxx: add flags for FID registers
  net: dsa: mv88e6xxx: expose mv88e6xxx_num_databases
  net: dsa: mv88e6xxx: add mv88e6xxx_num_ports helper
  net: dsa: mv88e6xxx: rename mv88e6xxx_vtu_stu_entry
  net: dsa: mv88e6xxx: rename mv88e6xxx_ops
  net: dsa: mv88e6xxx: add chip-wide ops
  net: dsa: mv88e6xxx: add set_switch_mac to ops
  net: dsa: mv88e6xxx: add eeprom ops

 drivers/net/dsa/mv88e6xxx/Makefile    |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 804 +++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/global1.c   |  34 ++
 drivers/net/dsa/mv88e6xxx/global1.h   |  23 +
 drivers/net/dsa/mv88e6xxx/global2.c   |  86 ++--
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 102 +++--
 6 files changed, 607 insertions(+), 443 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1.h

-- 
2.10.0
