From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 16 Nov 2008 23:52:07 -0800 (PST)
Message-ID: <20081116.235207.172965695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755615AbYKQHwI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 02:52:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm handling wired device driver patches directly while Jeff Garzik
is away.

A lot of little fixes, mostly in drivers, highlights:

1) e100 driver uses wrong DMA direction parameter to DMA mapping
   calls, fix from Jesse Brandeburg.

2) PHY layer checks "0xffffffff" for "no PHY present" but the interface=
s
   return a 16-bit value so this test never triggers.  Check the
   correct 16-bit 0xffff and also treat zero as "no PHY present".

   Fix from Giulio Benetti.

3) gianfar unmaps DMA memory in the wrong spot, fix from Andy Fleming.

4) lockdep build warning for bluetooth from Ingo Molnar

5) Device wakeup handling fixes for Intel drivers by Rafael J. Wysocki.

6) ISDN byteswapping regression fix by Harvey Harrison.

7) uec_get_ethtool_stats needs to be mindful of whether the device is
   up or not, otherwise it may dereference unallocated memory and OOPS,
   fix from Anton Vorontsov.

8) PHY library frees mii_bus object too early, fix from Lennert Buytenh=
ek.

9) New PHY variant support for NIU and Marvell PHY library driver,
   both cases only add new code and device IDs, ie. cases that
   beforehand would cause a probe failure.  Thanks to Ron Madrid
   and Santwona Behera.

10) Kill those INIT_LIST_HEAD() calls from the scm_destroy() recursion
    fix, superfluous, confusing, and wrong.  From Pavel Emelyanov.

Please pull, thanks a lot!

The following changes since commit b2af2c1d3e4ddeea9d02c46d0df0c322cc7b=
7061:
  Neil Horman (1):
        bnx2: fix poll_controller to pass proper structures and check a=
ll rx queues

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      net: shy netns_ok check

Andy Fleming (1):
      gianfar: Fix DMA unmap invocations

Anton Vorontsov (1):
      net/ucc_geth: Fix oops in uec_get_ethtool_stats()

Bjorn Helgaas (1):
      igb: use dev_printk instead of printk

Brian Haley (1):
      ipv6: routing header fixes

David S. Miller (2):
      niu: Bump driver version and release date.
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netd=
ev-2.6

Giulio Benetti (1):
      phy: fix phy address bug

Harvey Harrison (1):
      isdn: remove extra byteswap in isdn_net_ciscohdlck_slarp_send_rep=
ly

Ingo Molnar (1):
      lockdep: include/linux/lockdep.h - fix warning in net/bluetooth/a=
f_bluetooth.c

J. K. Cliburn (2):
      atl1e: fix broken multicast by removing unnecessary crc inversion
      atl1: Do not enumerate options unsupported by chip

Jeff Kirsher (2):
      e1000e: fix warn_on reload after phy_id error
      e1000e: fix IPMI traffic

Jesse Brandeburg (1):
      e100: fix dma error in direction for mapping

Joey Zhuo (1):
      via-velocity: enable perfect filtering for multicast packets

Johannes Berg (1):
      rtnetlink: propagate error from dev_change_flags in do_setlink()

Lennert Buytenhek (1):
      phylib: fix premature freeing of struct mii_bus

Pavel Emelyanov (1):
      scm: fix scm_fp_list->list initialization made in wrong place

Randy Dunlap (1):
      9p: restrict RDMA usage

Ron Madrid (1):
      phy: Add support for Marvell 88E1118 PHY

Ron Mercer (1):
      qla3xxx: Cleanup: Fix link print statements.

R=E9mi Denis-Courmont (1):
      Phonet: refuse to send bigger than MTU packets

Santwona Behera (1):
      NIU: Add Sun CP3260 ATCA blade support

Yevgeny Petrilin (1):
      mlx4_en: Pause parameters per port

\"Rafael J. Wysocki\ (3):
      e1000e: Use device_set_wakeup_enable
      e1000: Use device_set_wakeup_enable
      igb: Use device_set_wakeup_enable

 drivers/isdn/i4l/isdn_net.c       |    6 +-
 drivers/net/atl1e/atl1e_hw.c      |    4 -
 drivers/net/atlx/atl1.c           |   17 +--
 drivers/net/e100.c                |   20 ++--
 drivers/net/e1000/e1000_ethtool.c |    8 +-
 drivers/net/e1000/e1000_main.c    |    1 +
 drivers/net/e1000e/e1000.h        |    5 +
 drivers/net/e1000e/ethtool.c      |    8 +-
 drivers/net/e1000e/netdev.c       |   25 +++-
 drivers/net/e1000e/param.c        |   25 +++
 drivers/net/gianfar.c             |   15 +-
 drivers/net/igb/igb_ethtool.c     |    8 +-
 drivers/net/igb/igb_main.c        |    8 +-
 drivers/net/mlx4/en_netdev.c      |    8 +-
 drivers/net/mlx4/en_params.c      |   30 ++--
 drivers/net/mlx4/mlx4_en.h        |    8 +-
 drivers/net/niu.c                 |  290 +++++++++++++++++++++++++++++=
+++++++-
 drivers/net/niu.h                 |   13 ++
 drivers/net/phy/marvell.c         |   66 +++++++++
 drivers/net/phy/mdio_bus.c        |    2 +-
 drivers/net/phy/phy_device.c      |    4 +-
 drivers/net/qla3xxx.c             |   19 +--
 drivers/net/ucc_geth_ethtool.c    |    6 +-
 drivers/net/via-velocity.c        |    2 +-
 include/linux/lockdep.h           |    5 +-
 include/net/sock.h                |    2 +-
 net/9p/Kconfig                    |   10 +-
 net/core/rtnetlink.c              |    4 +-
 net/core/scm.c                    |    2 -
 net/core/sock.c                   |    2 -
 net/ipv4/ip_input.c               |   10 +-
 net/ipv6/datagram.c               |    5 +
 net/ipv6/ipv6_sockglue.c          |    5 +
 net/phonet/af_phonet.c            |    4 +-
 34 files changed, 532 insertions(+), 115 deletions(-)
