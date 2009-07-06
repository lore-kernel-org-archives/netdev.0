From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 06 Jul 2009 14:51:46 -0700 (PDT)
Message-ID: <20090706.145146.67549924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753535AbZGFVvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 17:51:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) e1000e and ixgbe regression fixes from Bruce Allan, Don Skidmore,
   Mallikarjuna R Chilakala, and Jeff Kirsher.

2) BNX2X fixes from Eilon Greenstein.

3) Fix TUN unregister race resuling in oops.  From Herbert Xu.

4) TUN polling can oops in ->poll() due to a change added this merge
   window, fix from Mariusz Kozlowski.

5) qlge bug fixes from Ron Mercer.

6) smsc911x.c sizes resource regions incorrectly, fix from Julia Lawall.

7) Fix for forcedeth NAPI race reported by Ingo Molnar, fix from
   Eric Dumazet.

8) DSA stats snapshotting fix from Stephane Contri.

9) be2net gets spurious interrupts in INTX mode, from Sathya Perla.

10) PHY_RESUMING state mishandled in phylib, fix from Wade Farnsworth.

11) SCTP ports and protocol incorrectly read from packets in IPSEC
    layer.  Fix from Wei Yongjun.

12) SCTP frees packets twice, fix also from Wei Yongjun.

13) Two gigaset fixes from Tilman Schmidt.

14) New device ID for pcnet_cs driver.

15) Revert a change causing crashes in P54 wireless driver.

There are some ominous looking crashes in the TTY layer when using PPP
over USB serial devices, as one example, and Alan Cox is working on
pushing changes to fix that.

Please pull, thanks a lot!

The following changes since commit 8e4a718ff38d8539938ec3421935904c27e00c39:
  Linus Torvalds (1):
        Linux 2.6.31-rc2

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhishek Kulkarni (1):
      net/9p: Fix crash due to bad mount parameters.

Alexander Duyck (1):
      if_ether: add define for 1588 aka Timesync

Brian Haley (1):
      IPv6: preferred lifetime of address not getting updated

Bruce Allan (6):
      e1000e: PHY loopback broken on 82578
      e1000e: delay after LCD reset and proper checks for PHY configuration done
      e1000e: do not write SmartSpeed register bits on parts without support
      e1000e: prevent NVM corruption on sectors larger than 4K
      e1000e: delay second read of PHY_STATUS register on failure of first read
      e1000e: disable K1 at 1000Mbps for 82577/82578

David S. Miller (1):
      Revert "p54: Use SKB list handling helpers instead of by-hand code."

Dhananjay Phadke (2):
      netxen: fix the version code macro
      netxen: avoid frequent firmware reset

Don Skidmore (3):
      ixgbe: fix issues with failing to detect insert of unsupported module
      ixgbe: fix regression on some 82598 adapters
      ixgbe: fix inconsistent SFP/SFP+ failure results.

Eilon Greenstein (2):
      bnx2x: Disable HC coalescing when setting timeout to zero.
      bnx2x: Fix the maximal values of coalescing timeouts.

Eric Dumazet (1):
      forcedeth: Fix NAPI race.

Herbert Xu (1):
      tun: Fix device unregister race

Julia Lawall (1):
      drivers/net/smsc911x.c: Fix resource size off by 1 error

Ken Kawasaki (1):
      pcnet_cs: add new id

Mallikarjuna R Chilakala (1):
      ixgbe: Not allow 8259x unsupported wol options change from ethtool

Mariusz Kozlowski (1):
      tun/tap: Fix crashes if open() /dev/net/tun and then poll() it.

Ron Mercer (8):
      qlge: Expand coverage of hw lock for config register.
      qlge: Clear frame to queue routing before reset.
      qlge: Fix carrier on condition.
      qlge: Fix redundant call to free resources.
      qlge: Fix tx byte counter.
      qlge: Fix MAC address bonding issue.
      qlge: Add/use function for link up/down.
      qlge: Fix sizeof usage.

Sathya Perla (1):
      be2net: fix spurious interrupt handling in intx mode

Stephane Contri (1):
      dsa: fix 88e6xxx statistics counter snapshotting

Tilman Schmidt (2):
      gigaset: accept connection establishment messages in any order
      gigaset: drop pointless check

Wade Farnsworth (1):
      phylib: fixes for PHY_RESUMING state changes

Wei Yongjun (3):
      xfrm4: fix the ports decode of sctp protocol
      xfrm6: fix the proto and ports decode of sctp protocol
      sctp: fix warning at inet_sock_destruct() while release sctp socket

 drivers/isdn/gigaset/ev-layer.c      |   44 +++---
 drivers/isdn/gigaset/isocdata.c      |    6 -
 drivers/net/benet/be_hw.h            |    4 +
 drivers/net/benet/be_main.c          |   16 +-
 drivers/net/bnx2x.h                  |    2 +
 drivers/net/bnx2x_main.c             |   12 +-
 drivers/net/e1000e/defines.h         |    3 +
 drivers/net/e1000e/hw.h              |    4 +
 drivers/net/e1000e/ich8lan.c         |  270 +++++++++++++++++++++++++++-------
 drivers/net/e1000e/lib.c             |    6 -
 drivers/net/e1000e/phy.c             |   12 ++-
 drivers/net/forcedeth.c              |   25 ++--
 drivers/net/ixgbe/ixgbe_ethtool.c    |    1 -
 drivers/net/ixgbe/ixgbe_main.c       |   32 +++--
 drivers/net/ixgbe/ixgbe_phy.c        |    3 +
 drivers/net/netxen/netxen_nic.h      |   17 ++-
 drivers/net/netxen/netxen_nic_hdr.h  |    1 +
 drivers/net/netxen/netxen_nic_init.c |  111 ++++++++++++---
 drivers/net/netxen/netxen_nic_main.c |    4 +
 drivers/net/pcmcia/pcnet_cs.c        |    1 +
 drivers/net/phy/phy.c                |   25 +++-
 drivers/net/qlge/qlge.h              |    2 +
 drivers/net/qlge/qlge_ethtool.c      |    4 +-
 drivers/net/qlge/qlge_main.c         |  153 ++++++++++++++-----
 drivers/net/qlge/qlge_mpi.c          |    6 +-
 drivers/net/smsc911x.c               |    6 +-
 drivers/net/tun.c                    |   20 ++-
 drivers/net/wireless/p54/p54common.c |   46 ++++---
 include/linux/if_ether.h             |    1 +
 net/9p/trans_fd.c                    |   14 +-
 net/dsa/mv88e6xxx.c                  |    2 +-
 net/ipv4/xfrm4_policy.c              |    3 +-
 net/ipv6/addrconf.c                  |   30 ++++-
 net/ipv6/xfrm6_policy.c              |    6 +-
 net/sctp/socket.c                    |   25 +---
 35 files changed, 658 insertions(+), 259 deletions(-)
