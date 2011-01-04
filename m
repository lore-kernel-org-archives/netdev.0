From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 04 Jan 2011 11:56:00 -0800 (PST)
Message-ID: <20110104.115600.245388910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some stragglers, the most important bit is the bridging multicast
crash cure.

1) MIPS build of starfire fails on some 64-bit platforms, fix from Ben
   Hutchings.

2) VLAN flags of ehea inadvertantly changed when modifying other
   feature flags.  Fix from Breno Leitao.

3) Don't expose kernel addresses in CAN proc files, from Dan
   Rosenberg.

4) skfp driver probe checks wrong return value for error, from Dan
   Carpenter.

5) Bridging netfilter expects SKB mac header to be initialized
   properly, a simplification made to the STP code inadvertantly broke
   that.  Fix from Florian Westphal.

6) tg3_read_vpd() checks return value incorrectly, fix from David
   Sterba.

7) Bridging code doesn't handle non-linear SKBs properly when parsing
   through ipv6 extension headers to get at the IGMP message bits.
   Fix from Tomas Winkler.

8) There's a rather pervasive CISCO ppp implementation bug regarding a
   corner case of compression and protocol IDs, add a sysctl to work
   around this so people can at least function while waiting for
   various CISCO kit to get updated.  From Stephen Hemminger.

9) Memory leaks in ISDN gigaset and broadcom CNIC drivers, from Jesper
   Juhl.

10) Changing ring parameters causes oops in atl1, fix from J. K. Cliburn.

11) In ipv4 we ignore preferred source address setting for local routes,
    fix from Joel Sing.

12) Device leak in atmtcp.c, fix from Julia Lawall.

Please pull, thanks a lot.

The following changes since commit 989d873fc5b6a96695b97738dea8d9f02a60f8ab:

  Merge master.kernel.org:/home/rmk/linux-2.6-arm (2011-01-03 16:37:01 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Hutchings (1):
      starfire: Fix dma_addr_t size test for MIPS

Breno Leitao (1):
      ehea: Avoid changing vlan flags

Dan Carpenter (1):
      skfp: testing the wrong variable in skfp_driver_init()

Dan Rosenberg (1):
      CAN: Use inode instead of kernel address for /proc file

Dan Williams (1):
      ueagle-atm: fix PHY signal initialization race

David Sterba (1):
      tg3: fix return value check in tg3_read_vpd()

Florian Westphal (1):
      bridge: stp: ensure mac header is set

J. K. Cliburn (1):
      atl1: fix oops when changing tx/rx ring params

Jesper Juhl (2):
      ISDN, Gigaset: Fix memory leak in do_disconnect_req()
      Broadcom CNIC core network driver: fix mem leak on allocation failures in cnic_alloc_uio_rings()

Joel Sing (1):
      ipv4/route.c: respect prefsrc for local routes

Julia Lawall (1):
      drivers/atm/atmtcp.c: add missing atm_dev_put

Tomas Winkler (1):
      bridge: fix br_multicast_ipv6_rcv for paged skbs

stephen hemminger (1):
      ppp: allow disabling multilink protocol ID compression

 drivers/atm/atmtcp.c            |    5 ++++-
 drivers/isdn/gigaset/capi.c     |    1 +
 drivers/net/atlx/atl1.c         |   10 ++++++++++
 drivers/net/cnic.c              |   10 ++++++++--
 drivers/net/ehea/ehea_ethtool.c |    7 +++++++
 drivers/net/ppp_generic.c       |    9 +++++++--
 drivers/net/skfp/skfddi.c       |    2 +-
 drivers/net/starfire.c          |    2 +-
 drivers/net/tg3.c               |    2 +-
 drivers/usb/atm/ueagle-atm.c    |   22 +++++++++++++++++++---
 net/bridge/br_multicast.c       |   28 ++++++++++++++++++----------
 net/bridge/br_stp_bpdu.c        |    2 ++
 net/can/bcm.c                   |    4 ++--
 net/ipv4/route.c                |    8 ++++++--
 14 files changed, 87 insertions(+), 25 deletions(-)
