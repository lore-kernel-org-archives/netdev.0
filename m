From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/7] net: dsa: change dsa_ptr for a dsa_port
Date: Fri, 29 Sep 2017 17:19:14 -0400
Message-ID: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With DSA, a master net_device is physically wired to a dedicated CPU
switch port. For interaction with the DSA layer, the struct net_device
contains a dsa_ptr, which currently points to a dsa_switch_tree object.

This is only valid for a switch fabric with a single CPU port. In order
to support switch fabrics with multiple CPU ports, we first need to
change the type of dsa_ptr to what it really is: a dsa_port object.

This is what this patchset does. The first patches adds a
dsa_master_get_slave helper and cleans up portions of DSA core to make
the next patches more readable. These next patches prepare the xmit and
receive hot paths and finally change dsa_ptr.

Changes in v2:
  - introduce dsa_master_get_slave helper to simplify patch 6
  - keep hot path data at beginning of dsa_port for cacheline 1

Vivien Didelot (7):
  net: dsa: add master helper to look up slaves
  net: dsa: use cpu_dp in master code
  net: dsa: use temporary dsa_device_ops variable
  net: dsa: add tagging ops to port
  net: dsa: prepare master receive hot path
  net: dsa: change dsa_ptr for a dsa_port
  net: dsa: remove tag ops from the switch tree

 include/linux/netdevice.h |  4 ++--
 include/net/dsa.h         | 19 ++++++++-----------
 net/dsa/dsa.c             |  6 +++---
 net/dsa/dsa2.c            | 15 ++++++++++-----
 net/dsa/dsa_priv.h        | 27 +++++++++++++++++++++------
 net/dsa/legacy.c          | 15 ++++++++++-----
 net/dsa/master.c          | 47 ++++++++++++++++++++++-------------------------
 net/dsa/slave.c           |  3 +--
 net/dsa/tag_brcm.c        |  9 ++-------
 net/dsa/tag_dsa.c         | 18 ++----------------
 net/dsa/tag_edsa.c        | 18 ++----------------
 net/dsa/tag_ksz.c         |  9 +++------
 net/dsa/tag_lan9303.c     | 20 ++------------------
 net/dsa/tag_mtk.c         | 16 +++-------------
 net/dsa/tag_qca.c         | 17 +++--------------
 net/dsa/tag_trailer.c     |  9 +++------
 16 files changed, 97 insertions(+), 155 deletions(-)

-- 
2.14.1
