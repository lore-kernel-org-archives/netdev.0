From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/9] net: dsa: preparatory patches for multi-chip
Date: Fri, 27 Jan 2017 15:29:35 -0500
Message-ID: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to introduce support for multi-chip configuration, we need to
do a few enhancements. This patchset makes the number of ports in a
switch dynamic (instead of capping to DSA_MAX_PORTS), stores the switch
and index of a port in the dsa_port structure, uses it in the slave
private structure, and exposes the bridge device a port belongs to.

Vivien Didelot (9):
  net: dsa: variable number of ports
  net: dsa: use ds->num_ports when possible
  net: dsa: add ds and index to dsa_port
  net: dsa: store a dsa_port in dsa_slave_priv
  net: dsa: move bridge device in dsa_port
  net: dsa: pass bridge device when a port leaves
  net: dsa: mv88e6xxx: use dsa_port's bridge pointer
  net: dsa: qca8k: use dsa_port's bridge pointer
  net: dsa: b53: use dsa_port's bridge pointer

 drivers/net/dsa/b53/b53_common.c      |  18 ++--
 drivers/net/dsa/b53/b53_priv.h        |   3 +-
 drivers/net/dsa/mv88e6xxx/chip.c      |  33 +++---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   6 --
 drivers/net/dsa/qca8k.c               |  17 ++--
 drivers/net/dsa/qca8k.h               |   1 -
 include/net/dsa.h                     |  12 ++-
 net/dsa/dsa.c                         |  21 ++--
 net/dsa/dsa2.c                        |  34 +++++--
 net/dsa/dsa_priv.h                    |   9 +-
 net/dsa/slave.c                       | 182 +++++++++++++++++-----------------
 net/dsa/tag_brcm.c                    |   6 +-
 net/dsa/tag_dsa.c                     |  10 +-
 net/dsa/tag_edsa.c                    |  10 +-
 net/dsa/tag_qca.c                     |   2 +-
 net/dsa/tag_trailer.c                 |   4 +-
 16 files changed, 186 insertions(+), 182 deletions(-)

-- 
2.11.0
