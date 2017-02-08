From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 0/2] mv88e6xxx Watchdog support
Date: Thu,  9 Feb 2017 00:03:41 +0100
Message-ID: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60469 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751357AbdBHXEB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 18:04:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell switches have an in built watchdog over some of the
internal state machine. The watchdog can be configured to raise an
interrupt on error. The problem the watchdog found is then logged to
the kernel log.

The older switches can automagically perform a software reset when the
watchdog triggers. This just resets the internal state machine, but
leaves the switch configuration unchanged.

The 6390 family of switches cannot both raise an interrupt and
automagically perform a software reset. So the interrupt handler has
to perform the switch reset, and then re-enable the watchdog
interrupts.

This has been tested using hacked together debugfs code which allows
the "force" bit to be set, so cause a watchdog interrupt.

v2: Remove g2_prefix

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Add watchdog interrupt handler
  net: dsa: mv88e6xxx: Add mv88e6390 watchdog interrupt support

 drivers/net/dsa/mv88e6xxx/chip.c      |  23 ++++++
 drivers/net/dsa/mv88e6xxx/global2.c   | 137 +++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h   |   6 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  33 ++++++++
 4 files changed, 198 insertions(+), 1 deletion(-)

-- 
2.11.0
