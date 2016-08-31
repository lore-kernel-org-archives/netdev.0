From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 11:50:02 -0400
Message-ID: <20160831155005.2569-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds the switchdev MDB object support to the DSA layer.

The MDB support for the mv88e6xxx driver is very similar to the FDB
support. The FDB operations care about unicast addresses while the MDB
operations care about multicast addresses.

Both operation set load/purge/dump the Address Translation Table (ATU),
thus common code is used.

Changes in v2 based on Andrew's comments:
  - drop "group" in multicast database related doc and comment
  - change _one for more relevant _fid in mv88e6xxx_port_db_dump_one
  - return -EOPNOTSUPP if switchdev obj ID is neither _FDB nor _MDB

Vivien Didelot (3):
  net: dsa: add MDB support
  net: dsa: mv88e6xxx: make switchdev DB ops generic
  net: dsa: mv88e6xxx: add MDB support

 Documentation/networking/dsa/dsa.txt |  23 +++++
 drivers/net/dsa/mv88e6xxx/chip.c     | 163 ++++++++++++++++++++++++++---------
 include/net/dsa.h                    |  16 ++++
 net/dsa/slave.c                      |  55 ++++++++++++
 4 files changed, 215 insertions(+), 42 deletions(-)

-- 
2.9.3
