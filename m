From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 01 Oct 2015 17:43:28 -0700 (PDT)
Message-ID: <20151001.174328.2107306212695015237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix regression in SKB partial checksum handling, from Pravin B
   Shalar.

2) Fix VLAN inside of VXLAN handling in i40e driver, from Jesse
   Brandeburg.

3) Cure softlockups during accept() in SCTP, from Karl Heiss.

4) MSG_PEEK should return multiple SKBs worth of data in AF_UNIX,
   from Aaron Conole.

5) IPV6 erroneously ignores output interface specifier in lookup
   key for route lookups, fix from David Ahern.

6) In Marvell DSA driver, forward unknown frames to CPU port, from
   Andrew Lunn.

7) Mission flow flag initializations in some code paths, from David
   Ahern.

Please pull, thanks a lot!

The following changes since commit 518a7cb6980cd640c7f979d29021ad870f60d7d7:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-09-26 06:01:33 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to b84f78782052ee4516903e5d0566a5eee365b771:

  net: Initialize flow flags in input path (2015-09-29 21:52:32 -0700)

----------------------------------------------------------------
Aaron Conole (2):
      af_unix: Convert the unix_sk macro to an inline function for type safety
      af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag

Alexander Couzens (1):
      l2tp: protect tunnel->del_work by ref_count

Alexander Stein (1):
      net sysfs: Print link speed as signed integer

Andrew Lunn (1):
      dsa: mv88e6xxx: Enable forwarding for unknown to the CPU port

Andrzej Hajda (3):
      net: hisilicon: fix handling platform_get_irq result
      r8169: fix handling rtl_readphy result
      bna: fix error handling

David Ahern (2):
      net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set
      net: Initialize flow flags in input path

David S. Miller (2):
      Merge branch 'sctp-accept-deadlock'
      Merge branch 'af_unix_MSG_PEEK'

Denys Vlasenko (1):
      net: sctp: Don't use 64 kilobyte lookup table for four elements

Ivan Mikhaylov (1):
      net/ibm/emac: bump version numbers for correct work with ethtool

Jesse Brandeburg (1):
      i40e: fix VLAN inside VXLAN

Karl Heiss (2):
      sctp: Whitespace fix
      sctp: Prevent soft lockup when sctp_accept() is called during a timeout event

Mitch Williams (1):
      i40e/i40evf: check for stopped admin queue

Pravin B Shelar (1):
      skbuff: Fix skb checksum partial check.

Robb Manes (1):
      net/mlx4: Handle return codes in mlx4_qp_attach_common

Thomas Huth (1):
      testptp: Silence compiler warnings on ppc64

Vivien Didelot (1):
      net: dsa: fix preparation of a port STP update

 Documentation/ptp/testptp.c                     |    1 +
 drivers/net/dsa/mv88e6xxx.c                     |    2 ++
 drivers/net/ethernet/brocade/bna/bfa_ioc.c      |   13 +++++++------
 drivers/net/ethernet/hisilicon/hip04_eth.c      |    2 +-
 drivers/net/ethernet/ibm/emac/core.h            |    6 +++---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |    9 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c     |    3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |    9 +++++++++
 drivers/net/ethernet/mellanox/mlx4/mcg.c        |    7 ++++---
 drivers/net/ethernet/realtek/r8169.c            |    2 +-
 include/linux/skbuff.h                          |    2 +-
 include/net/af_unix.h                           |    6 +++++-
 net/core/net-sysfs.c                            |    3 +--
 net/core/skbuff.c                               |    9 +++++----
 net/dsa/slave.c                                 |   11 ++++++++---
 net/ipv4/fib_frontend.c                         |    1 +
 net/ipv4/route.c                                |    1 +
 net/ipv6/route.c                                |    3 ++-
 net/l2tp/l2tp_core.c                            |   11 +++++++++--
 net/sctp/associola.c                            |   20 +++++++++++---------
 net/sctp/sm_sideeffect.c                        |   44 ++++++++++++++++++++++++--------------------
 net/unix/af_unix.c                              |   15 ++++++++++++++-
 22 files changed, 121 insertions(+), 59 deletions(-)
