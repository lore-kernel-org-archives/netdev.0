From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 07 Oct 2009 04:19:54 -0700 (PDT)
Message-ID: <20091007.041954.229456480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758970AbZJGLUB@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Device ID additions for IXGBE, and some CIS additions for
   pcmcia networking devices.

2) Two pktgen fixes from Eric Dumazet.   Packet delays regressed
   in this merge window and the multiqueue support doesn't handle
   specifying exactly one specific queue to use properly.

3) Kill libc5 crap from linux/socket.h, that just makes it impossible
   to include sys/socket.h after it in userland apps.  From Ben Hutchings.

4) e1000e regression fix, limitation on jumbo frames was applied to
   wrong chip IDs.  From Alexander Duyck.

5) get_wireless_stats() executes get stats operations in a different
   context than it normally would, they need to be able to sleep.
   So when getting stats from sysfs, use rtnl mutex instead of
   dev_base_lock.  From Johannes Berg.

6) be2net flash operation submission, ethtool TX checksumming,
   multicast frame accounting, and macro definition fixes from Ajit
   Khaparde.

7) tg3 PHY library locking was bolixed, fixed by Matt Carlson.

8) Improperly paren'd unlikely() statement in netxen driver, fix from
   Roel Kluin.

9) qlge bug fixes from Ron Mercer

10) Fix from Stephen Hemminger for arp_notify, it can crash with
    a NULL pointer if there are no IPV4 addresses attached to the
    interface at notification time.  With help from Eric Dumazet.

11) ethoc bug fixes from Thomas Chou

12) Deal with the backlog of ISDN bug fixes from Tilman Schmidt,
    Karsten hasn't been respinsive for 2 or 3 weeks so I'm handling
    ISDN stuff starting now until he can find time again.

13) pasemi_mac can oops on a NULL pointer on ethtool get-settings
    calls with some PHY types, fix from Valentine Barshak.

14) au1000_eth tests wrong bits for RX errors, fix from Roel Kluin.

Please pull, thanks a lot!

The following changes since commit 0eca52a92735f43462165efe00a7e394345fb38e:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/ide-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (4):
      be2net: Fix a bug in preparation of mcc wrb which was causing flash operation to fail
      be2net: Bug Fix while accounting of multicast frames during netdev stats update
      be2net: Fix a typo in be_cmds.h
      be2net: Bug fix to properly update ethtool tx-checksumming after ethtool -K <ifname> tx off

Alexander Duyck (1):
      e1000e: swap max hw supported frame size between 82574 and 82583

Ben Hutchings (1):
      net: Support inclusion of <linux/socket.h> before <sys/socket.h>

Don Skidmore (2):
      ixgbe: add support for 82599 Combined Backplane
      ixgbe: add support for 82599 based X520 10G Dual KX4 Mezz card

Eric Dumazet (2):
      pktgen: Fix multiqueue handling
      pktgen: restore nanosec delays

Johannes Berg (1):
      wext: let get_wireless_stats() sleep

John W. Linville (1):
      rndis_host: support ETHTOOL_GPERMADDR

Ken Kawasaki (1):
      pcnet_cs: add cis of National Semicondoctor's multifunction pcmcia card

Matt Carlson (1):
      tg3: Fix phylib locking strategy

Neil Horman (1):
      add maintainer for network drop monitor kernel service

Roel Kluin (1):
      netxen: Fix Unlikely(x) > y

Ron Mercer (3):
      qlge: Fix some bit definitions for reset register.
      qlge: Fix queueing of firmware handler in ISR.
      qlge: Fix lock/mutex warnings.

Stephen Boyd (1):
      connector: Fix incompatible pointer type warning

Stephen Hemminger (1):
      ipv4: arp_notify address list bug

Thomas Chou (5):
      ethoc: fix typo to compute number of tx descriptors
      ethoc: fix buffer address mapping
      ethoc: align received packet to make IP header at word boundary
      ethoc: use system memory as buffer
      ethoc: limit the number of buffers to 128

Tilman Schmidt (12):
      Documentation: expand isdn/INTERFACE.CAPI document
      isdn: accept CAPI Informational Info values as success
      isdn: avoid races in capidrv
      isdn: make capidrv module parameter "debugmode" writeable
      gigaset: fix reject/hangup handling
      gigaset: linearize skb
      gigaset: handle isoc frame errors more gracefully
      gigaset: announce if built with debugging
      gigaset: fix device ERROR response handling
      gigaset: improve error recovery
      gigaset: correct debugging output selection
      gigaset: add kerneldoc comments

Valentine Barshak (1):
      pasemi_mac: ethtool get settings fix

roel kluin (1):
      au1000_eth: Duplicate test of RX_OVERLEN bit in update_rx_stats()

 Documentation/isdn/INTERFACE.CAPI    |   83 +++++++++++++++++----
 Documentation/networking/pktgen.txt  |    8 ++
 MAINTAINERS                          |    7 ++
 drivers/connector/cn_proc.c          |    3 +-
 drivers/isdn/capi/capi.c             |    2 +-
 drivers/isdn/capi/capidrv.c          |   27 ++++---
 drivers/isdn/gigaset/asyncdata.c     |   28 +++++---
 drivers/isdn/gigaset/bas-gigaset.c   |   87 +++++++++++++---------
 drivers/isdn/gigaset/common.c        |  134 ++++++++++++++++++++++++++++------
 drivers/isdn/gigaset/ev-layer.c      |   30 +++++---
 drivers/isdn/gigaset/i4l.c           |   23 ++++++
 drivers/isdn/gigaset/interface.c     |    9 ++
 drivers/isdn/gigaset/isocdata.c      |   30 ++++---
 drivers/net/au1000_eth.c             |    4 +-
 drivers/net/benet/be_cmds.c          |    1 -
 drivers/net/benet/be_cmds.h          |    2 +-
 drivers/net/benet/be_ethtool.c       |    2 +-
 drivers/net/benet/be_main.c          |    6 +-
 drivers/net/e1000e/82571.c           |    4 +-
 drivers/net/ethoc.c                  |   81 ++++++++++++++-------
 drivers/net/ixgbe/ixgbe_82599.c      |    2 +
 drivers/net/ixgbe/ixgbe_main.c       |    4 +
 drivers/net/ixgbe/ixgbe_type.h       |    2 +
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 drivers/net/pasemi_mac_ethtool.c     |    3 +
 drivers/net/pcmcia/pcnet_cs.c        |   10 +-
 drivers/net/qlge/qlge.h              |    8 +-
 drivers/net/qlge/qlge_ethtool.c      |    2 -
 drivers/net/qlge/qlge_main.c         |   18 +---
 drivers/net/qlge/qlge_mpi.c          |   12 ++-
 drivers/net/tg3.c                    |   41 ++++-------
 drivers/net/tg3.h                    |    1 -
 drivers/net/usb/rndis_host.c         |    1 +
 drivers/serial/serial_cs.c           |   12 ++--
 firmware/Makefile                    |    7 +-
 firmware/WHENCE                      |    5 +
 firmware/cis/COMpad2.cis.ihex        |   11 +++
 firmware/cis/COMpad4.cis.ihex        |    9 ++
 firmware/cis/DP83903.cis.ihex        |   14 ++++
 firmware/cis/NE2K.cis.ihex           |    8 ++
 firmware/cis/tamarack.cis.ihex       |   10 +++
 include/linux/socket.h               |   21 +-----
 net/core/net-sysfs.c                 |    4 +-
 net/core/pktgen.c                    |    4 +-
 net/ipv4/devinet.c                   |   16 +++--
 45 files changed, 545 insertions(+), 253 deletions(-)
 create mode 100644 firmware/cis/COMpad2.cis.ihex
 create mode 100644 firmware/cis/COMpad4.cis.ihex
 create mode 100644 firmware/cis/DP83903.cis.ihex
 create mode 100644 firmware/cis/NE2K.cis.ihex
 create mode 100644 firmware/cis/tamarack.cis.ihex
