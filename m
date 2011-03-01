From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/7] Final BKL removal, take 2
Date: Wed,  2 Mar 2011 00:13:04 +0100
Message-ID: <1299021191-17961-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-fsdevel@vger.kernel.org, linux-x25@vger.kernel.org,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Max Vozeler <max@vozeler.com>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org, Nick Bowler <nbowler@elliptictech.com>,
	Nick Piggin <npiggin@gmail.com>,
	Palash Bandyopadhyay <palash.bandyopadhyay@conexant.com>,
	Takahiro Hirofuchi <hirofuchi@users.sourceforge.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:53198 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757016Ab1CAXNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:13:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the set of patches that remain from
my previous submission one month ago. I've
dropped the ones that have either gone into
linux-next or got a sufficient number of
Acked-by:s so I put them into my own tree.

I've updated the usbip, hpfs, ufs and appletalk
patches according to the feedback I got.

If possible, I'd like the three networking patches
to go through the net-next tree, and the two
staging patches through the staging tree. I'll
add the other ones to my own series if I hear
no objections.

	Arnd

Arnd Bergmann (7):
  staging/usbip: convert to kthread
  staging/cx25721: serialize access to devlist
  hpfs: remove the BKL
  ufs: remove the BKL
  x25: remove the BKL
  appletalk: remove the BKL
  ipx: remove the BKL

 drivers/net/appletalk/Kconfig           |    1 -
 drivers/staging/cx25821/Kconfig         |    1 -
 drivers/staging/cx25821/cx25821-alsa.c  |    2 +
 drivers/staging/cx25821/cx25821-core.c  |   16 ++---
 drivers/staging/cx25821/cx25821-video.c |    9 +--
 drivers/staging/cx25821/cx25821.h       |    3 +-
 drivers/staging/usbip/Kconfig           |    2 +-
 drivers/staging/usbip/stub.h            |    4 +-
 drivers/staging/usbip/stub_dev.c        |   12 ++--
 drivers/staging/usbip/stub_rx.c         |   13 ++---
 drivers/staging/usbip/stub_tx.c         |   17 +++---
 drivers/staging/usbip/usbip_common.c    |  105 -------------------------------
 drivers/staging/usbip/usbip_common.h    |   20 +-----
 drivers/staging/usbip/usbip_event.c     |   38 ++++-------
 drivers/staging/usbip/vhci.h            |    4 +-
 drivers/staging/usbip/vhci_hcd.c        |   10 ++-
 drivers/staging/usbip/vhci_rx.c         |   16 ++---
 drivers/staging/usbip/vhci_sysfs.c      |    9 +--
 drivers/staging/usbip/vhci_tx.c         |   17 +++---
 fs/hpfs/Kconfig                         |    2 +-
 fs/hpfs/dir.c                           |   23 +++----
 fs/hpfs/file.c                          |    9 +--
 fs/hpfs/hpfs_fn.h                       |   22 +++++++
 fs/hpfs/inode.c                         |    9 +--
 fs/hpfs/namei.c                         |   49 +++++++-------
 fs/hpfs/super.c                         |   23 +++----
 fs/ufs/Kconfig                          |    1 -
 fs/ufs/inode.c                          |   78 ++++++-----------------
 fs/ufs/namei.c                          |   35 +++++-----
 fs/ufs/super.c                          |   64 +++++++++++--------
 fs/ufs/truncate.c                       |    5 +-
 fs/ufs/ufs.h                            |    6 ++-
 fs/ufs/util.c                           |    2 +-
 net/appletalk/ddp.c                     |   40 +++++-------
 net/ipx/Kconfig                         |    1 -
 net/ipx/af_ipx.c                        |   52 ++++++---------
 net/x25/Kconfig                         |    1 -
 net/x25/af_x25.c                        |   58 +++++------------
 net/x25/x25_out.c                       |    7 ++-
 39 files changed, 296 insertions(+), 490 deletions(-)

Cc: Andi Kleen <ak@linux.intel.com>
Cc: Andrew Hendry <andrew.hendry@gmail.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Evgeniy Dushistov <dushistov@mail.ru>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-x25@vger.kernel.org
Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: Max Vozeler <max@vozeler.com>
Cc: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: netdev@vger.kernel.org
Cc: Nick Bowler <nbowler@elliptictech.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Palash Bandyopadhyay <palash.bandyopadhyay@conexant.com>
Cc: Takahiro Hirofuchi <hirofuchi@users.sourceforge.net>
