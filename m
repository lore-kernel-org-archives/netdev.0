From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 0/5] Retrieving Ethernet PHY wireup from the OF device tree
Date: Tue, 10 Mar 2009 09:21:56 -0600
Message-ID: <20090310150751.12455.70598.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:39859 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbZCJPWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 11:22:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This series reworks some of the phylib code to allow PHY descriptions and
connections to be extracted from the OF device tree.  MDIO bus drivers gain
a common helper function for parsing the PHY data and registering new
phy_devices to match.  Ethernet controller drivers gain the ability to
resolve to a phy_device from a device tree phandle.

One notable aspect is that the Ethernet controller driver doesn't know
if the phy_device is registered before or after the Ethernet driver.  This
series adds a function to the device model core code to make it simple for
the driver to register a bus notifier (mdio_bus in this case), which gets
called both for existing devices and for future device registrations.  The
advantage of this is that the driver doesn't need to know or care when the
device actually shows up.  It just knows that its callback will get called
when the device is available.  I think this is a good approach, but I'd
appreciate some feedback on it.

Cheers,
g.

drivers/base/bus.c            |   47 +++++++++
 drivers/net/Kconfig           |    2 +-
 drivers/net/fec_mpc52xx.c     |  220 ++++++++++++++++++-----------------------
 drivers/net/fec_mpc52xx_phy.c |   30 +++---
 drivers/net/phy/mdio_bus.c    |   29 +-----
 drivers/net/phy/phy_device.c  |  161 +++++++++++++++++++++++-------
 drivers/of/Kconfig            |    6 +
 drivers/of/Makefile           |    1 +
 drivers/of/of_mdio.c          |   70 +++++++++++++
 include/linux/device.h        |    2 +
 include/linux/of_mdio.h       |   20 ++++
 include/linux/phy.h           |    6 +
 12 files changed, 388 insertions(+), 206 deletions(-)

--
Grant Likely, B.Sc. P.Eng.
Secret Lab Technologies Ltd.
