From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/6] mv88e6xxx broadcast flooding in hardware
Date: Wed, 27 Sep 2017 00:25:57 +0200
Message-ID: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:57015 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969562AbdIZW1V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 18:27:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes the mv88e6xxx driver perform flooding in hardware,
rather than let the software bridge perform the flooding. This is a
prerequisite for IGMP snooping on the bridge interface.

In order to make hardware broadcasting work, a few other issues need
fixing or improving. SWITCHDEV_ATTR_ID_PORT_PARENT_ID is broken, which
is apparent when testing on the ZII devel board with multiple
switches.

Some of these patches are taken from a previous RFC patchset of IGMP
support. Hence the v2 comments...


Andrew Lunn (6):
  net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
  net: dsa: {e}dsa: set offload_fwd_mark on received packets
  net: dsa: mv88e6xxx: Fixed port netdev check for VLANs
  net: dsa: mv88e6xxx: Print offending port when vlan check fails
  net: dsa: mv88e6xxx: Move mv88e6xxx_port_db_load_purge()
  net: dsa: mv88e6xxx: Flood broadcast frames in hardware

 drivers/net/dsa/mv88e6xxx/chip.c | 128 ++++++++++++++++++++++++---------------
 net/dsa/slave.c                  |  11 ++--
 net/dsa/tag_dsa.c                |   1 +
 net/dsa/tag_edsa.c               |   1 +
 4 files changed, 89 insertions(+), 52 deletions(-)

-- 
2.14.1
