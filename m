From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 00/14] net: dsa: mv88e6xxx: rework ATU support
Date: Thu,  9 Mar 2017 18:33:10 -0500
Message-ID: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose of this patch series is to rework the code related to the
Address Translation Unit (ATU), and bring support for it to the 88E6390
family of switch chips.

All Global (1) ATU related code have been reworked and moved to its own
file. Some port related bits used for ATU configuration (such as the
Learn2All and MessagePort feature) have also been taken care of.

The ports' mode and egress flooding mode have been refactored to fix the
egress of frames with unknown unicast or multicast destination address,
and write all these bits regardless the port mode (Normal, DSA, etc.)

Finally remove the eth_addr_greater which was only used by mv88e6xxx.

Vivien Didelot (14):
  net: dsa: mv88e6xxx: add port mask helper
  net: dsa: mv88e6xxx: move ATU ageing time setter
  net: dsa: mv88e6xxx: setup ATU Learn2All
  net: dsa: mv88e6xxx: rework ATU Load/Purge
  net: dsa: mv88e6xxx: rework ATU GetNext
  net: dsa: mv88e6xxx: rework ATU Flush
  net: dsa: mv88e6xxx: rework ATU Remove
  net: dsa: mv88e6xxx: rename new FID helper
  net: dsa: mv88e6xxx: rename the port vector member
  net: dsa: mv88e6xxx: rework port mode setup
  net: dsa: mv88e6xxx: fix port egress flooding mode
  net: dsa: mv88e6xxx: add port ATU learn limit op
  net: dsa: mv88e6xxx: add port priority override op
  etherdevice: remove unused eth_addr_greater

 drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c        | 670 +++++++++++---------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  11 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 300 ++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  31 +-
 drivers/net/dsa/mv88e6xxx/port.c        |  78 +++-
 drivers/net/dsa/mv88e6xxx/port.h        |  16 +-
 include/linux/etherdevice.h             |  15 -
 8 files changed, 632 insertions(+), 490 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_atu.c

-- 
2.12.0
