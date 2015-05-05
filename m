From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 00/10] More Marvell DSA refactring and fixup
Date: Wed,  6 May 2015 01:09:46 +0200
Message-ID: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44529 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995AbbEEXPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:15:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch setup continues the refactoring and cleanup of the Marvell
DSA drivers.

Patch #1 Centralizes the duplicated parts of port setup and global
setup into the shared mv88e6xxx.

Patch #2 Centralizes looping over the ports setting them up

Patch #3 Uses mnemonics for the remaining register access in the
drivers.

Patch #4 The 6172 is actually a member of the 6352 family. This moves
the probe code into the correct driver.

Patch #5 Adds more members of the 6171 family to the 6171 driver. The
new devices are untested.

Patch #6 The 6185 is a member of the 6131 family. Add it to the probe
code of the 6131 driver.

Patch #7 and Patch #8 Simply the mutex's in mv88e6xxx.c. The SMI bus
is the bottleneck, not the granularity of the mutex's so simply the
code down to a single mutex.

Patch #8 Fixes a false positive lockdep splat, due to nested uses of
MDIO busses.

Patch #9 Fixes another false positive lockdep splat with the transmit
queue because of stacked Ethernet devices.

Andrew Lunn (10):
  net: dsa: Centralise global and port setup code into mv88e6xxx.
  net: dsa: Centralize setting up ports
  net: dsa: Converting remaining registers to mnemonics
  net: dsa: Move mv88e6172 support into mv88e6352 family driver
  net: dsa: mv88e6171: Add other members of the family
  net: dsa: mv88e6131: Add support for mv88e6185
  net: dsa: mv88e6xxx: Replace PHY mutex by SMI mutex
  net: dsa: mv88e6xxx: Replace stats mutex with SMI mutex
  net: dsa: mv88e6xxx: Fix false positive lockdep splat
  net: dsa: Add lockdep class to tx queues to avoid lockdep splat

 drivers/net/dsa/Kconfig           |  12 +-
 drivers/net/dsa/mv88e6123_61_65.c | 186 +----------
 drivers/net/dsa/mv88e6131.c       | 185 ++---------
 drivers/net/dsa/mv88e6171.c       | 234 ++------------
 drivers/net/dsa/mv88e6352.c       | 188 +----------
 drivers/net/dsa/mv88e6xxx.c       | 636 +++++++++++++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx.h       |  99 +++++-
 net/dsa/slave.c                   |  14 +-
 8 files changed, 719 insertions(+), 835 deletions(-)

-- 
2.1.4
