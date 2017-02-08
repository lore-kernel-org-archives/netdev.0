From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 0/2] mv88e6xxx Watchdog support
Date: Wed, 8 Feb 2017 01:39:16 +0100
Message-ID: <20170208003916.GA28551@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59416 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755466AbdBHBKh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 20:10:37 -0500
Received: from andrew by vps0.lunn.ch with local (Exim 4.80)
        (envelope-from <andrew@lunn.ch>)
        id 1cbGI0-0007S6-PF
        for netdev@vger.kernel.org; Wed, 08 Feb 2017 01:39:16 +0100
Content-Disposition: inline
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
