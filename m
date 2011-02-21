From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 0/9] ax88796: cleanups and convert to phylib and mdio_bitbang
Date: Mon, 21 Feb 2011 14:03:11 +0100
Message-ID: <1298293400-21570-1-git-send-email-mkl@pengutronix.de>
Cc: Ben Dooks <ben@fluff.org>, Daniel Mack <daniel@caiaq.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35841 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706Ab1BUND2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 08:03:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this patch series fixes the phy-read/write problems of the ax88796
(see http://www.spinics.net/lists/arm-kernel/msg98982.html).

Patches 1-8 clean verious aspects of the driver. The 9th patch replaces the
handcrafted mdio bitbang loop with the generic mdio_bitbang driver.

This patch series has been tested on the Toradex colibri-320. With the patch
mii-diag gives sound data:

root@grabowski:~ mii-diag
Using the default interface 'eth0'.
Basic registers of MII PHY #16:  3100 782d 003b 1841 01e1 45e1 0003 0000.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x3100: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 45e1: Flow-control 100baseTx-FD 100baseTx 10baseT-FD 10baseT, w/ 802.3X flow control.
   End of basic transceiver information.

please review and consider to appply.

regards, Marc

---

The series applies to net-next-2.6/master and can be pulled:

The following changes since commit 59ed5aba9ca1c799e272b352d5d2d7fe12bd32e8:

  sctp: fix compile warnings in sctp_tsnmap_num_gabs (2011-02-20 11:10:15 -0800)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git net/ax88796

Marc Kleine-Budde (9):
      ax88796: fix codingstyle and checkpatch warnings
      ax88796: don't use magic ei_status to acces private data
      ax88796: remove memset of private data
      ax88796: remove first_init parameter from ax_init_dev()
      ax88796: use netdev_<LEVEL> instead of dev_<LEVEL> and pr_<LEVEL>
      ax88796: remove platform_device member from struct ax_device
      ax88796: make pointer to platform data const
      ax88796: clean up probe and remove function
      ax88796: use generic mdio_bitbang driver

 drivers/net/Kconfig   |    4 +-
 drivers/net/ax88796.c |  810 ++++++++++++++++++++++++-------------------------
 2 files changed, 395 insertions(+), 419 deletions(-)



