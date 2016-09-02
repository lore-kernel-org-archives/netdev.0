From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: mv88e6xxx: isolate Global2 support
Date: Fri,  2 Sep 2016 08:08:16 -0400
Message-ID: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Registers of Marvell chips are organized in internal SMI devices.

One of them at address 0x1C is called Global2. It provides an extended
set of registers, used for interrupt control, EEPROM access, indirect
PHY access (to bypass the PHY Polling Unit) and cross-chip setup.

Most chips have it, but some others don't (older ones such as 6060).

Now that its related code is isolated in mv88e6xxx_g2_* functions, move
it to its own global2.c file, making most of its setup code static.

Then make its compilation optional, which allows to reduce the size of
the mv88e6xxx driver for devices such as home routers embedding Ethernet
chips without Global2 support.

It is present on most recent chips, thus enable its support by default.

Vivien Didelot (3):
  net: dsa: mv88e6xxx: fix module naming
  net: dsa: mv88e6xxx: move Global2 code
  net: dsa: mv88e6xxx: make global2 code optional

 drivers/net/dsa/mv88e6xxx/Kconfig     |  11 +
 drivers/net/dsa/mv88e6xxx/Makefile    |   4 +-
 drivers/net/dsa/mv88e6xxx/chip.c      | 461 +--------------------------------
 drivers/net/dsa/mv88e6xxx/global2.c   | 470 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  58 +++++
 5 files changed, 553 insertions(+), 451 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global2.c

-- 
2.9.3
