From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/9] net: dsa: define port types
Date: Thu, 26 Oct 2017 11:22:50 -0400
Message-ID: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA code currently has 3 bitmaps in the dsa_switch structure:
cpu_port_mask, dsa_port_mask and enabled_port_mask.

They are used to store the type of each switch port. This dates back
from when DSA didn't have a dsa_port structure to hold port-specific
data.

The dsa_switch structure is mainly used to communicate with DSA drivers
and must not contain such static data parsed from DTS or pdata, which
belongs the DSA core structures, such as dsa_switch_tree and dsa_port.

Also the enabled_port_mask is misleading, often misinterpreted as the
complement of disabled ports (thus including DSA and CPU ports), while
in fact it only masks the user ports.

A port can be of 3 types when it is not unused: "cpu" (interfacing with
a master device), "dsa" (interconnecting with another "dsa" port from
another switch chip), or "user" (user-facing port.)

This patchset first fixes the usage of DSA port type helpers, then
defines the DSA_PORT_TYPE_UNUSED, DSA_PORT_TYPE_CPU, DSA_PORT_TYPE_DSA,
and DSA_PORT_TYPE_USER port types, and finally removes the misleading
port bitmaps.

Vivien Didelot (9):
  net: dsa: add dsa_is_unused_port helper
  net: dsa: mv88e6xxx: skip unused ports
  net: dsa: fix dsa_is_normal_port helper
  net: dsa: rename dsa_is_normal_port helper
  net: dsa: use dsa_is_user_port everywhere
  net: dsa: introduce dsa_user_ports helper
  net: dsa: define port types
  net: dsa: use new port type in helpers
  net: dsa: remove port masks

 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/bcm_sf2.c        |  9 ++++-----
 drivers/net/dsa/bcm_sf2_cfp.c    |  2 +-
 drivers/net/dsa/mt7530.c         |  6 +++---
 drivers/net/dsa/mv88e6060.c      |  5 ++---
 drivers/net/dsa/mv88e6xxx/chip.c |  5 ++++-
 drivers/net/dsa/qca8k.c          |  7 +++----
 include/net/dsa.h                | 39 ++++++++++++++++++++++++++++++---------
 net/dsa/dsa.c                    |  2 +-
 net/dsa/dsa2.c                   | 16 ++++------------
 net/dsa/legacy.c                 | 15 +++++++++------
 11 files changed, 62 insertions(+), 46 deletions(-)

-- 
2.14.3
