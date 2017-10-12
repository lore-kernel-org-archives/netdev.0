From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/5] net: dsa: master and slave helpers
Date: Thu, 12 Oct 2017 18:51:51 -0400
Message-ID: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
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

A dsa_slave_get_master returns the master device of a slave device.

After that the netdev member of the dsa_port structure is split into two
explicit master and slave members to avoid confusion, even though it is
not planned to create a slave for DSA or CPU ports for the moment.

Vivien Didelot (5):
  net: dsa: use port's cpu_dp when creating a slave
  net: dsa: add slave notify helper
  net: dsa: add slave to port helper
  net: dsa: add slave get master helper
  net: dsa: split dsa_port's netdev member

 drivers/net/dsa/bcm_sf2.c        |   6 +-
 drivers/net/dsa/mt7530.c         |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |   2 +-
 include/net/dsa.h                |   7 +-
 net/dsa/dsa.c                    |   6 +-
 net/dsa/dsa2.c                   |  22 ++--
 net/dsa/dsa_priv.h               |  22 ++--
 net/dsa/legacy.c                 |  20 ++--
 net/dsa/slave.c                  | 227 +++++++++++++++++++--------------------
 net/dsa/tag_brcm.c               |   9 +-
 net/dsa/tag_dsa.c                |  10 +-
 net/dsa/tag_edsa.c               |  10 +-
 net/dsa/tag_ksz.c                |   4 +-
 net/dsa/tag_lan9303.c            |   4 +-
 net/dsa/tag_mtk.c                |   4 +-
 net/dsa/tag_qca.c                |   5 +-
 net/dsa/tag_trailer.c            |   4 +-
 17 files changed, 183 insertions(+), 181 deletions(-)

-- 
2.14.2
