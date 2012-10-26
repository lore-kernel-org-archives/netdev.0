From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v4] Network driver for the Armada 370 and Armada XP ARM Marvell SoCs
Date: Fri, 26 Oct 2012 12:03:20 +0200
Message-ID: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:45229 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780Ab2JZKEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 06:04:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Lennert,

This patch set adds a new network driver for the network unit
available in the newest Marvell ARM SoCs Armada 370 and Armada XP, as
well as the necessary Device Tree information to use this driver in
the two evaluation platforms of those SoCs.

In details:

 * Patch 1 contains the driver itself. The commit log contains a
   detailed explanation about why a new driver is needed for this new
   Marvell SoC, compared to older Marvell SoCs (Orion, Kirkwood, Dove)
   that use the mv643xx_eth driver.

 * Patch 2 adds the necessary entry to the MAINTAINERS file.

 * Patch 3 adds the SoC-level Device Tree information for Armada 370
   and Armada XP.

 * Patch 4 adds the board-level Device Tree information for the
   Marvell evaluation boards of Armada 370 and Armada XP.

Changes since v3:
 * Use phy_find_first() to get the correct PHY. Suggested by Florian
   Fainelli.
 * Make pp->cause_rx_tx a simple variable instead of a per-CPU array
   since it is not useful. Fixes a comment raised by David Miller.

Changes since v2:
 * Change compatible string from 'marvell,neta' to
   'marvell,armada-370-neta'. Requested by Rob Herring.
 * Rename Ethernet DT nodes from eth@... to ethernet@... Requested by
   Rob Herring.
 * Remove device_type DT property. Requested by Rob Herring.
 * Change the PHY interface for eth0/eth1 to be rgmii-id, which allows
   to enable TX/RX delay mechanisms at the PHY level. This fixes CRC
   errors on received packets during iperf tests (it was a bug in v2).
 * Remove the mvneta_ prefix from module parameters. Requested by
   Baruch Siach.
 * Many code style improvements suggested by Fran=C3=A7ois Romieu.
 * Properly stop/restart the TX queue when the number of TX
   descriptors available becomes low, instead of returning
   NETDEV_TX_BUSY. Requested by Fran=C3=A7ois Romieu.
 * Properly drop packets on the TX path when DMA mapping functions
   return an error, instead of returning NETDEV_TX_BUSY. Requested by
   Fran=C3=A7ois Romieu.
 * Rebased on top of Linux 3.7-rc2.

Changes since v1:
 * Reduced the Cc: list in order to make the patch set acceptable for
   the netdev@ mailing list.
 * Merge the mvneta.h contents into mvneta.c, since the header was
   only used by the driver. Requested by Arnd Bergmann.
 * Completely reorganize the organization of the register list and
   register values, in order to make it more consistent, and hopefully
   easier to read (especially easier to match register values with the
   corresponding register).
 * Integrate with the phylib, as suggested by Florian Fainelli, and
   remove the link management code that has become useless as the
   result of this integration
 * Fix many small details suggested by Florian Fainelli in his review
   of the first driver
 * Simplify various parts of the driver (descriptors array allocation,
   data structures, etc.)

Thanks,

Thomas Petazzoni
