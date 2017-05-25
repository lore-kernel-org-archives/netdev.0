From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v3 net-next 0/5] net: dsa: mv88e6xxx: Add basic SERDES support
Date: Fri, 26 May 2017 01:03:19 +0200
Message-ID: <1495753404-29943-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45073 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760337AbdEYXDt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 19:03:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the Marvell switches are SERDES interface, which must be
powered up before packets can be passed. This is particularly true on
the 6390, where the SERDES defaults to down, probably to save power.

This series refactors the existing SERDES support for the 6352, and
adds 6390 support.

v2:

Split phy functions out into phy.[ch]
Don't add MV88E6XXX_FLAG_G1_ATU_FID back again
Move the serdes op up in mv88e6xxx_ops
Move some #defines into serdes.h
Add a mv88e6xxx_serdes_power()
Don't keep moving calls to this helper around in the code

v3:

Move more phy functions into phy.[ch]
Make mv88e6xxx_phy_page_get() and mv88e6xxx_phy_page_put static
Use the mv88e6xxx_serdes_power() helper everywhere
dev_err(...) when mv88e6xxx_serdes_power() fails
Add reviewed-by's

Andrew Lunn (5):
  net: dsa: mv88e6xxx: Move phy functions into phy.[ch]
  net: dsa: mv88e6xxx: Refactor mv88e6352 SERDES code into an op
  net: dsa: mv88e6xxx: Remove SERDES flag
  net: dsa: mv88e6xxx: mv88e6390X SERDES support
  dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable

 drivers/net/dsa/mv88e6xxx/Makefile    |   2 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 331 ++++++----------------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  31 +---
 drivers/net/dsa/mv88e6xxx/phy.c       | 243 +++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/phy.h       |  37 ++++
 drivers/net/dsa/mv88e6xxx/serdes.c    | 229 +++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/serdes.h    |  48 +++++
 7 files changed, 623 insertions(+), 298 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/phy.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/phy.h
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/serdes.h

-- 
2.11.0
