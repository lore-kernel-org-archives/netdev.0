From: Paul Collins <paul@briny.ondioline.org>
Subject: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Mon, 26 Jun 2006 12:28:03 +1000
Message-ID: <87ac80ps5o.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:50962 "EHLO
	jenny.ondioline.org") by vger.kernel.org with ESMTP
	id S1751409AbWFZCaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 22:30:09 -0400
To: Michael Buesch <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the bcm43xx periodic work patches that recently made it into
Linus's tree, my PowerBook does not survive running overnight.

Yesterday I reverted

91769e7dd9cef7988dc4280f74ed168351beb5b8 [PATCH] bcm43xx: preemptible periodic work
78ff56a06edc3407996173daf63e48f6b90c7062 [PATCH] bcm43xx: redesign locking

and it was still alive this morning.

The following is logged, but that may not be all since the screen was
turned off and kern.log was marked for no-fsync.

Jun 24 06:53:41 briny kernel: NETDEV WATCHDOG: eth1: transmit timed out
Jun 24 06:53:41 briny kernel: bcm43xx: Controller RESET (TX timeout) ...
Jun 24 06:53:41 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
Jun 24 06:53:41 briny kernel: bcm43xx: Number of cores: 5
Jun 24 06:53:41 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
Jun 24 06:53:41 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
Jun 24 06:53:41 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
Jun 24 06:53:41 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
Jun 24 06:53:41 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
Jun 24 06:53:41 briny kernel: bcm43xx: PHY connected
Jun 24 06:53:41 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
Jun 24 06:53:41 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
Jun 24 06:53:41 briny kernel: bcm43xx: Radio turned off
Jun 24 06:53:41 briny kernel: bcm43xx: Radio turned off
Jun 24 06:53:41 briny kernel: bcm43xx: Controller restarted

Config options:

  CONFIG_BCM43XX=m
  CONFIG_BCM43XX_DEBUG=y
  CONFIG_BCM43XX_DMA=y
  CONFIG_BCM43XX_PIO=y
  CONFIG_BCM43XX_DMA_AND_PIO_MODE=y
  # CONFIG_BCM43XX_DMA_MODE is not set
  # CONFIG_BCM43XX_PIO_MODE is not set

And "preemptible" made me check for PREEMPT options:

  # CONFIG_PREEMPT_NONE is not set
  CONFIG_PREEMPT_VOLUNTARY=y
  # CONFIG_PREEMPT is not set

-- 
Paul Collins
Melbourne, Australia

Dag vijandelijk luchtschip de huismeester is dood
