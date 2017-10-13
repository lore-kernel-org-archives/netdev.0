From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Fri, 13 Oct 2017 14:18:04 -0400
Message-ID: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Laight <David.Laight@ACULAB.COM>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An Ethernet switch may support having a MAC address, which can be used
as the switch's source address in transmitted full-duplex Pause frames.

If a DSA switch supports the related .set_addr operation, the DSA core
sets the master's MAC address on the switch.

This won't make sense anymore in a multi-CPU ports system, because there
won't be a unique master device assigned to a switch tree.

Moreover this operation is confusing because it makes the user think
that it could be used to program the switch with the MAC address of the
CPU/management port such that MAC address learning can be disabled on
said port, but in fact, that's not how it is currently used.

To fix this, assign a random MAC address at setup time in the mv88e6060
and mv88e6xxx drivers before removing .set_addr completely from DSA.

Changes in v3:
  - include fix for mv88e6060 switch MAC address setter.

Changes in v2:
  - remove .set_addr implementation from drivers and use a random MAC.

Vivien Didelot (5):
  net: dsa: mv88e6xxx: setup random mac address
  net: dsa: mv88e6060: fix switch MAC address
  net: dsa: mv88e6060: setup random mac address
  net: dsa: dsa_loop: remove .set_addr
  net: dsa: remove .set_addr

 drivers/net/dsa/dsa_loop.c       |  8 --------
 drivers/net/dsa/mv88e6060.c      | 37 ++++++++++++++++++++++++++-----------
 drivers/net/dsa/mv88e6xxx/chip.c | 33 +++++++++++++++++----------------
 include/net/dsa.h                |  1 -
 net/dsa/dsa2.c                   |  6 ------
 net/dsa/legacy.c                 |  6 ------
 6 files changed, 43 insertions(+), 48 deletions(-)

-- 
2.14.2
