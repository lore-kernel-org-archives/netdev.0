From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 08 Feb 2010 22:59:58 -0800 (PST)
Message-ID: <20100208.225958.78128071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Most notable bits here are the netfilter conntack namespace
fixes, and the sky2 DMA mapping leak fix.

1) Bluetooth fixes from Marcel Holtmann and co.

   a) Missing kfree() leads to leak
   b) Double put on RFCOMM sockets
   c) Handle SCO 0x1a errors (Unsupported Remote Feature)
   d) Fix user copy outside of proper context
   e) RFCOMM sleeping in invalid context

2) dst_gc() needs to preempt, fix from Eric Dumazet.

3) Netxen fixes (tx timeout adjustment for NX2031, protect
   resource cleanups with proper locking) from Amit Kumar Salecha

4) IGB fix wrt. legacy interrupt vectors handling after reset from
   Alexander Duyck.

5) Serious netfilter conntrack fixes wrt. namespaces from Patrick
   McHardy, Alexey Dobriyan, and Eric Dumazet.

6) Fix DCCP slab cache et al. regressions, from Gerrit Renker.

7) IXGBE can sometimes select invalid TXQ, fix from Krishna Kumar.

8) Two IRDA fixes from Thadeu Lima de Souza Cascardo

   a) Unbalanced lock_kernel() in irnet_ppp
   b) BKL missed in irnet_ppp ioctl conversion

9) SKY2 driver leaks DMA mappings on transmit, fix from
   Stephen Hemminger.

10) When passing packets up to GRO, validate chip checksum
    properly in cxgb3.  Fix from Divy Le Ray.

11) IXGBE TX packet mapping error path fix from Anton Blanchard.

12) AF_KEY module load/unload fix wrt. net namespace ops
    from Alexey Dobriyan.

13) Several doc, Kconfig help, and MAINTAINERS tidies.

Please pull, thanks a lot!

The following changes since commit deb0c98c7f6035d47a247e548384517a955314a5:
  Linus Torvalds (1):
        Merge branch 'for-2.6.33' of git://linux-nfs.org/~bfields/linux

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      igb: make certain to reassign legacy interrupt vectors after reset

Alexey Dobriyan (4):
      af_key: fix netns ops ordering on module load/unload
      netlink: fix for too early rmmod
      netfilter: nf_conntrack: restrict runtime expect hashsize modifications
      netfilter: xtables: compat out of scope fix

Amit Kumar Salecha (2):
      netxen: fix tx timeout recovery for NX2031 chip
      netxen: protect resource cleanup by rtnl lock

Anton Blanchard (1):
      ixgbe: Fix ixgbe_tx_map error path

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Divy Le Ray (1):
      cxgb3: fix GRO checksum check

Eric Dumazet (2):
      netfilter: nf_conntrack: per netns nf_conntrack_cachep
      dst: call cond_resched() in dst_gc_task()

Gerrit Renker (2):
      dccp: fix bug in cache allocation
      dccp: fix auto-loading of dccp(_probe)

Jan Luebbe (1):
      net/sched: Fix module name in Kconfig

Joe Perches (1):
      MAINTAINERS: networking drivers - Add git net-next tree

Julia Lawall (1):
      drivers/net: Correct NULL test

Krishna Kumar (1):
      ixgbe: Fix return of invalid txq

Marcel Holtmann (1):
      Bluetooth: Fix sleeping function in RFCOMM within invalid context

Michael Poole (1):
      Bluetooth: Keep a copy of each HID device's report descriptor

Nick Pelly (3):
      Bluetooth: Fallback eSCO to SCO on error 0x1a (Unsupported Remote Feature)
      Bluetooth: Do not call rfcomm_session_put() for RFCOMM UA on closed socket
      Bluetooth: Enter active mode before establishing a SCO link.

Patrick McHardy (2):
      netfilter: nf_conntrack: fix memory corruption with multiple namespaces
      netfilter: nf_conntrack: fix hash resizing with namespaces

Rafael J. Wysocki (1):
      pktgen: Fix freezing problem

Thadeu Lima de Souza Cascardo (2):
      irda: unbalanced lock_kernel in irnet_ppp
      irda: add missing BKL in irnet_ppp ioctl

Yoichi Yuasa (1):
      Bluetooth: Fix memory leak in Marvell BT-over-SDIO driver

stephen hemminger (1):
      sky2: fix transmit DMA map leakage

 MAINTAINERS                                        |    1 +
 drivers/bluetooth/btmrvl_sdio.c                    |    1 +
 drivers/net/ax88796.c                              |    2 +-
 drivers/net/cxgb3/sge.c                            |   20 ++--
 drivers/net/igb/igb_main.c                         |   20 +---
 drivers/net/ixgbe/ixgbe_main.c                     |    7 +-
 drivers/net/netxen/netxen_nic_main.c               |    4 +-
 drivers/net/sky2.c                                 |    8 +-
 include/net/netns/conntrack.h                      |    3 +
 include/net/netns/ipv4.h                           |    1 +
 net/bluetooth/hci_conn.c                           |    3 +
 net/bluetooth/hci_event.c                          |    1 +
 net/bluetooth/hidp/core.c                          |   49 ++++----
 net/bluetooth/hidp/hidp.h                          |    4 +-
 net/bluetooth/rfcomm/core.c                        |    8 +-
 net/core/dst.c                                     |    2 +
 net/core/pktgen.c                                  |    1 +
 net/dccp/ccid.c                                    |    2 +-
 net/dccp/ccid.h                                    |    8 +-
 net/dccp/probe.c                                   |    4 +-
 net/ipv4/netfilter/arp_tables.c                    |    4 +-
 net/ipv4/netfilter/ip_tables.c                     |    4 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    2 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    4 +-
 net/ipv4/netfilter/nf_nat_core.c                   |   22 ++--
 net/ipv6/netfilter/ip6_tables.c                    |    4 +-
 net/irda/irnet/irnet_ppp.c                         |    5 +-
 net/key/af_key.c                                   |   15 ++-
 net/netfilter/nf_conntrack_core.c                  |  116 +++++++++++---------
 net/netfilter/nf_conntrack_expect.c                |    4 +-
 net/netfilter/nf_conntrack_helper.c                |    2 +-
 net/netfilter/nf_conntrack_netlink.c               |    2 +-
 net/netfilter/nf_conntrack_standalone.c            |    7 +-
 net/netlink/af_netlink.c                           |    5 +
 net/sched/Kconfig                                  |   16 ++--
 35 files changed, 197 insertions(+), 164 deletions(-)
