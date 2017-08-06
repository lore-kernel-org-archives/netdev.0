From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next v3 00/13] Update DSA's FDB API and perform switchdev cleanup
Date: Sun,  6 Aug 2017 16:15:38 +0300
Message-ID: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com, Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44704 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751256AbdHFNMN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 09:12:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patchset adds support for configuring static FDB entries via the
switchdev notification chain. The current method for FDB configuration
uses the switchdev's bridge bypass implementation. In order to support 
this legacy way and to perform the switchdev cleanup, the implementation
is moved inside DSA.

The DSA drivers cannot sync the software bridge with hardware learned
entries and use the switchdev's implementation of bypass FDB dumping.
Because they are the only ones using this functionality, the fdb_dump
implementation is moved from switchdev code into DSA.

Finally after this changes a major cleanup in switchdev can be done.
---
Please see individual patches for patch specific change logs.
v1->v2
- Split MDB/vlan dump removal into core/driver removal.

v2->v3
- The self implementation for FDB add/del is moved inside DSA.

Arkadi Sharshevsky (13):
  net: dsa: Change DSA slave FDB API to be switchdev independent
  net: dsa: Remove prepare phase for FDB
  net: dsa: Remove switchdev dependency from DSA switch notifier chain
  net: dsa: Add support for learning FDB through notification
  net: dsa: Move FDB add/del implementation inside DSA
  net: dsa: Add support for querying supported bridge flags
  net: dsa: Remove support for vlan dump from DSA's drivers
  net: dsa: Remove support for bypass bridge port attributes/vlan set
  net: dsa: Remove support for MDB dump from DSA's drivers
  net: dsa: Remove redundant MDB dump support
  net: dsa: Move FDB dump implementation inside DSA
  net: bridge: Remove FDB deletion through switchdev object
  net: switchdev: Remove bridge bypass support from switchdev

 drivers/net/dsa/b53/b53_common.c       |  83 +-----
 drivers/net/dsa/b53/b53_priv.h         |  16 +-
 drivers/net/dsa/bcm_sf2.c              |   2 -
 drivers/net/dsa/dsa_loop.c             |  38 ---
 drivers/net/dsa/microchip/ksz_common.c | 124 ++------
 drivers/net/dsa/mt7530.c               |  41 +--
 drivers/net/dsa/mv88e6xxx/chip.c       | 147 ++--------
 drivers/net/dsa/qca8k.c                |  42 +--
 include/net/dsa.h                      |  23 +-
 include/net/switchdev.h                |  87 ------
 net/bridge/br_fdb.c                    |  18 --
 net/dsa/dsa.c                          |  13 +
 net/dsa/dsa_priv.h                     |  29 +-
 net/dsa/legacy.c                       |  22 ++
 net/dsa/port.c                         |  51 +---
 net/dsa/slave.c                        | 249 +++++++++++++---
 net/dsa/switch.c                       |  21 +-
 net/switchdev/switchdev.c              | 519 ---------------------------------
 18 files changed, 360 insertions(+), 1165 deletions(-)

-- 
2.4.11
