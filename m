From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v5] Network driver for the Armada 370 and Armada XP ARM Marvell SoCs
Date: Mon, 12 Nov 2012 18:07:03 +0100
Message-ID: <1352740030-12801-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:40047 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab2KLRHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:07:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

This patch set adds a new network driver for the network unit
available in the newest Marvell ARM SoCs Armada 370 and Armada XP, as
well as the necessary Device Tree information to use this driver in
the two evaluation platforms of those SoCs.

The previous versions of this patch set have been sent on September
4th (v1), October 11th (v2), October 23rd (v3), October 26th (v4) and
now comes the v5 of the driver. The number of comments over the last
versions have been really small, and I would really appreciate if this
driver could land into the 3.8 kernel release.

People interested in testing this driver can find it at:

 git@github.com:MISL-EBU-System-SW/mainline-public.git marvell-neta-v5

In details:

 * Patch 1 contains a small driver for the MDIO interface of this
   Ethernet controller. Having a separate driver is useful to more
   easily handle concurrent accesses on this MDIO interface that is
   shared between all Ethernet ports.

 * Patch 3 contains the driver itself. The commit log contains a
   detailed explanation about why a new driver is needed for this new
   Marvell SoC, compared to older Marvell SoCs (Orion, Kirkwood, Dove)
   that use the mv643xx_eth driver.

 * Patch 4 adds the necessary entry to the MAINTAINERS file.

 * Patch 5 adds the SoC-level Device Tree information for Armada 370
   and Armada XP.

 * Patch 6 adds the board-level Device Tree information for the
   Marvell evaluation boards of Armada 370 and Armada XP.

 * Patch 6 adds the board-level Device Tree information for the
   PlatHome OpenBlocks AX3-4 platform (based on the Armada XP SoC).

 * Patch 7 adds the board-level Device Tree information for the
   GlobalScale Mirabox platform (based on the Armada 370 SoC).

Changes since v4:
 * Added a separate MDIO driver, which allow to easily handle
   concurrent accesses to the MDIO interface.
 * The Device Tree now has separate nodes for the PHY devices, which
   belong to the MDIO bus handled by the separate MDIO driver.
 * Fix tabulation issues in some Device Tree files.
 * Rebased on top of 3.7-rc5
 * Added the Device Tree code necessary for the GlobalScale Mirabox
   platform and the PlatHome OpenBlocks AX3-4 platform.

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
