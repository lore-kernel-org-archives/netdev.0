From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/4] net: dsa: move master ethtool code
Date: Tue, 19 Sep 2017 11:56:56 -0400
Message-ID: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA core overrides the master device's ethtool_ops structure so that
it can inject statistics and such of its dedicated switch CPU port.

This ethtool code is currently called on unnecessary conditions or
before the master interface and its switch CPU port get wired up.
This patchset fixes this.

Similarly to slave.c where the DSA slave net_device is the entry point
of the dsa_slave_* functions, this patchset also isolates the master's
ethtool code in a new master.c file, where the DSA master net_device is
the entry point of the dsa_master_* functions.

This is a first step towards better control of the master device and
support for multiple CPU ports.

Vivien Didelot (4):
  net: dsa: remove copy of master ethtool_ops
  net: dsa: setup master ethtool unconditionally
  net: dsa: setup master ethtool after dsa_ptr
  net: dsa: move master ethtool code

 include/net/dsa.h  |   1 -
 net/dsa/Makefile   |   2 +-
 net/dsa/dsa.c      |  28 -------------
 net/dsa/dsa2.c     |  18 ++++----
 net/dsa/dsa_priv.h |   7 ++--
 net/dsa/legacy.c   |  10 ++---
 net/dsa/master.c   | 120 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    |  80 -----------------------------------
 8 files changed, 136 insertions(+), 130 deletions(-)
 create mode 100644 net/dsa/master.c

-- 
2.14.1
