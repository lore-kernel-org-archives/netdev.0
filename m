From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 00/11] Start adding support for mv88e6390
Date: Mon, 21 Nov 2016 23:26:54 +0100
Message-ID: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47753 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753809AbcKUWa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 17:30:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first patchset implementing support for the mv88e6390
family.  This is a new generation of switch devices and has numerous
incompatible changes to the registers. These patches allow the switch
to the detected during probe, and makes the statistics unit work.

These patches are insufficient to make the mv88e6390 functional. More
patches will follow.

v2:
  Move stats code into global1
  Change DT compatible string to mv88e6190
  Fixed mv88e6351 stats which v1 had broken

Andrew Lunn (11):
  net: dsa: mv88e6xxx: Take switch out of reset before probe
  net: dsa: mv88e6xxx: Fix unused variable warning by using variable
  net: dsa: mv88e6xxx: Add the mv88e6390 family
  net: dsa: mv88e6xxx: Abstract stats_snapshot into ops structure
  net: dsa: mv88e6xxx: Add comment about family a device belongs to
  net: dsa: mv88e6xxx: Add mv88e6390 stats snapshot operation
  net: dsa: mv88e6xxx: Add mv88e6390 statistics unit init
  net: dsa: mv88e6xxx: Add stats_get_sset_count|string to ops structure
  net: dsa: mv88e6xxx: Add stats_get_stats to ops structure
  net: dsa: mv88e6xxx: Implement mv88e6390 get_stats
  net: dsa: mv88e6xxx: Move g1 stats code in global1.[ch]

 .../devicetree/bindings/net/dsa/marvell.txt        |   3 +-
 drivers/net/dsa/mv88e6xxx/chip.c                   | 643 +++++++++++++++------
 drivers/net/dsa/mv88e6xxx/global1.c                |  94 +++
 drivers/net/dsa/mv88e6xxx/global1.h                |   6 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  58 +-
 5 files changed, 629 insertions(+), 175 deletions(-)

-- 
2.10.2
