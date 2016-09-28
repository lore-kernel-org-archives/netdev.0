From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/6] net: dsa: mv88e6xxx: Implement interrupt support.
Date: Wed, 28 Sep 2016 12:22:20 +0200
Message-ID: <20160928102220.GC19407@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34995 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbcI1KWY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 06:22:24 -0400
Content-Disposition: inline
In-Reply-To: <1475051544-18561-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cover email got rejected, because i used MV88E6XXX in the subject
line, and it did not like the XXX.

----------------------------------------------------------------------

>From 838e38d8079341ffdeb98c3c1bf043627c24cfc2 Mon Sep 17 00:00:00 2001
From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 28 Sep 2016 03:23:04 -0500
Subject: [PATCH RFC 0/6] Interrupt support for MV88E6XYZ

NOT FOR MERGING

This RFC patchset add interrupt controller support to the MV88E6XXX.
This allows access to the interrupts the internal PHY generate. These
interrupts can then be associated to a PHY device in the device tree
and used by the PHY lib, rather than polling.

An earlier version of these patches were posted many moons ago. They
have been rebased onto net-next and adapted to the new structure of
the driver. However, still outstanding is if this is the correct way
to implement this feature, via an IRQ domain made available in the
device tree, and then using the standard PHY binding. This was
questioned last time, and never really resolved.

Comment welcome.

	Andrew

Andrew Lunn (6):
  net: dsa: mv88e6xxx: Implement interrupt support.
  net: phy: Use threaded IRQ, to allow IRQ from sleeping devices
  net: phy: Threaded interrupts allow some simplification
  net: phy: Use phy name when requesting the interrupt
  net: phy: Trigger state machine on state change and not polling.
  arm: vf610: zii devel b: Add support for switch interrupts

 .../devicetree/bindings/net/dsa/marvell.txt        |  21 +-
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          |  51 +++++
 drivers/net/dsa/mv88e6xxx/chip.c                   | 247 ++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.c                | 140 +++++++++++-
 drivers/net/dsa/mv88e6xxx/global2.h                |  11 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  32 ++-
 drivers/net/phy/phy.c                              |  66 +++---
 drivers/net/phy/phy_device.c                       |   1 -
 include/linux/phy.h                                |   4 +-
 9 files changed, 529 insertions(+), 44 deletions(-)

-- 
2.9.3
