From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next 00/11] Change DSA's FDB API and perform switchdev cleanup
Date: Tue, 18 Jul 2017 17:20:13 +0300
Message-ID: <1500387624-4361-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36000 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751413AbdGROQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 10:16:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patchset moves the DSA driver into learning static FDB entries via
the switchdev notification chain rather then by using bridge bypass SELF
flag. 

The DSA drivers cannot sync the software bridge with hardware learned
entries and use the switchdev's implementation of bypass FDB dumping.
Because they are the only ones using this functionality, the fdb_dump
implementation is moved from switchdev code into DSA.

Finally after this changes a major cleanup in switchdev can be done.

Arkadi Sharshevsky (11):
  net: dsa: Change DSA slave FDB API to be switchdev independent
  net: dsa: Remove prepare phase for FDB
  net: dsa: Remove switchdev dependency from DSA switch notifier chain
  net: dsa: Add support for learning FDB through notification
  net: dsa: Remove support for FDB add/del via SELF
  net: dsa: Add support for querying supported bridge flags
  net: dsa: Remove support for bypass bridge port attributes/vlan set
  net: dsa: Remove redundant MDB dump support
  net: dsa: Move FDB dump implementation inside DSA
  net: bridge: Remove FDB deletion through switchdev object
  net: switchdev: Remove bridge bypass support from switchdev

 drivers/net/dsa/b53/b53_common.c       |  85 +-----
 drivers/net/dsa/b53/b53_priv.h         |  16 +-
 drivers/net/dsa/bcm_sf2.c              |   2 -
 drivers/net/dsa/dsa_loop.c             |  38 ---
 drivers/net/dsa/microchip/ksz_common.c | 125 +++-----
 drivers/net/dsa/mt7530.c               |  44 +--
 drivers/net/dsa/mv88e6xxx/chip.c       | 148 ++--------
 drivers/net/dsa/qca8k.c                |  40 +--
 include/net/dsa.h                      |  25 +-
 include/net/switchdev.h                |  87 ------
 net/bridge/br_fdb.c                    |  18 --
 net/dsa/dsa.c                          |  13 +
 net/dsa/dsa_priv.h                     |  21 +-
 net/dsa/port.c                         |  51 +---
 net/dsa/slave.c                        | 247 +++++++++++++---
 net/dsa/switch.c                       |  21 +-
 net/switchdev/switchdev.c              | 519 ---------------------------------
 17 files changed, 341 insertions(+), 1159 deletions(-)

-- 
2.4.11
