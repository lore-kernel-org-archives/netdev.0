From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/7] net: dsa: master and slave helpers
Date: Mon, 16 Oct 2017 11:12:12 -0400
Message-ID: <20171016151219.22023-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds a few helpers to DSA core for clarity and
readability but brings no functional changes.

A dsa_slave_notify helper calls the DSA notifiers when (un)registering a
slave device.

Most of the DSA slave code only needs to access the dsa_port structure,
not the dsa_slave_priv (which only contains a few PHY-specific members).
Thus a dsa_slave_to_port helper returns a dsa_port structure of a slave
device.

A dsa_slave_to_master returns the master device of a slave device.

After that the netdev member of the dsa_port structure is split into two
explicit master and slave members to avoid confusion, and a dsa_to_port
helper is added for switch drivers to get a const reference to a port.

Changes in v2:
  - prefer dsa_slave_to_master instead of dsa_slave_get_master
  - rename dsa_master_get_slave to dsa_master_find_slave
  - pack master and slave net devices into an anonymous union
  - add dsa_to_port public helper for switch drivers
  - add Reviewed-by tags from Florian

Vivien Didelot (7):
  net: dsa: use port's cpu_dp when creating a slave
  net: dsa: add slave notify helper
  net: dsa: add slave to port helper
  net: dsa: add slave to master helper
  net: dsa: rename dsa_master_get_slave
  net: dsa: split dsa_port's netdev member
  net: dsa: add dsa_to_port helper

 drivers/net/dsa/b53/b53_common.c |   4 +-
 drivers/net/dsa/bcm_sf2.c        |   6 +-
 drivers/net/dsa/lan9303-core.c   |   2 +-
 drivers/net/dsa/mt7530.c         |   6 +-
 drivers/net/dsa/mv88e6060.c      |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |  10 +-
 drivers/net/dsa/qca8k.c          |   4 +-
 include/net/dsa.h                |  14 ++-
 net/dsa/dsa.c                    |   6 +-
 net/dsa/dsa2.c                   |  20 ++--
 net/dsa/dsa_priv.h               |  26 +++--
 net/dsa/legacy.c                 |  20 ++--
 net/dsa/slave.c                  | 227 +++++++++++++++++++--------------------
 net/dsa/tag_brcm.c               |  11 +-
 net/dsa/tag_dsa.c                |  12 +--
 net/dsa/tag_edsa.c               |  12 +--
 net/dsa/tag_ksz.c                |   6 +-
 net/dsa/tag_lan9303.c            |   6 +-
 net/dsa/tag_mtk.c                |   6 +-
 net/dsa/tag_qca.c                |   7 +-
 net/dsa/tag_trailer.c            |   6 +-
 21 files changed, 211 insertions(+), 202 deletions(-)

-- 
2.14.2
