From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 16 Mar 2010 14:54:44 -0700 (PDT)
Message-ID: <20100316.145444.71951587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Several bridging fixes from YOSHIFUJI Hideaki, Herbert Xu,
   and Michael Braun.

2) Gigaset ISDN driver fixes from Tilman Schmidt.

3) Several fixes via Andrew Morton including:

	Two Isdn4Linux fixes from Ian Munsie.
	Remove obsolete kconfig references from Christoph Egger
	Use for_each_set_bit() in phonet and atm from Akinobu Mita

4) L2TP OOPS and socket refcount bug fixes from James Chapman.

5) procfs rejects slashes in request_irq() names, fix for NE
   driver from Atsushi Nemoto.

6) Remove dead code in myri driver, from Dan Carpenter.

7) DCCP oopses if initialization fails, fix from Gerrit Renker.

8) Fix lock imbalance in ksz884x and NULL deref fix in netpoll
   from Jiri Slaby.

9) be2net big-endian bug fix from Ajit Khaparde.

10) Add SMSC97xx USB gigabit driver from Steve Glandinning.

    Fix PHY reset completion in SMSX95xx driver, also from Steve.

11) davinci driver build broke due to removal of deprecated
    DMA cache flushing interfaces, use dma_{map,unmap}_*() instead.
    From Sekhar Nori.

12) Add missing ISDN PCI device IDs, from Lars Ellenberg.

13) bnx2x memory barrier fixes from Stanislaw Gruszka.

14) Routing cache timer can crash in timer code due to missed
    synchronization, fix by using mod_timer(), from Vitaliy Gusev.

Please pull, thanks a lot!

The following changes since commit a3d3203e4bb40f253b1541e310dc0f9305be7c84:
  Linus Torvalds (1):
        Merge branch 'release' of git://git.kernel.org/.../lenb/linux-acpi-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: fix mccq create for big endian architectures

Akinobu Mita (2):
      phonet: use for_each_set_bit()
      atm: use for_each_set_bit()

Atsushi Nemoto (1):
      ne: Do not use slashes in irq name string

Christoph Egger (2):
      obsolete config in kernel source: USE_INTERNAL_TIMER
      obsolete config in kernel source: HSO_AUTOPM

Dan Carpenter (1):
      myri: remove dead code

David S. Miller (3):
      e100: Fix ring parameter change handling regression.
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      bridge: Make first arg to deliver_clone const.

Gerrit Renker (1):
      net-2.6 [Bug-Fix][dccp]: fix oops caused after failed initialisation

Herbert Xu (1):
      bridge: Move NULL mdb check into br_mdb_ip_get

Ian Munsie (2):
      i4l: silence compiler warnings for array access in Eicon DIVA ISDN driver
      i4l: change magic numbers in Eicon DIVA ISDN driver to symbolic names

James Chapman (2):
      l2tp: Fix oops in pppol2tp_xmit
      l2tp: Fix UDP socket reference count bugs in the pppol2tp driver

Jiri Slaby (2):
      NET: ksz884x, fix lock imbalance
      NET: netpoll, fix potential NULL ptr dereference

Julia Lawall (1):
      drivers/net: drop redundant memset

Lars Ellenberg (1):
      ISDN: Add PCI ID for HFC-2S/4S Beronet Card PCIe

Michael Braun (1):
      bridge: Fix br_forward crash in promiscuous mode

Neil Horman (1):
      tipc: fix lockdep warning on address assignment

Randy Dunlap (1):
      timestamping: fix example build

Roel Kluin (1):
      isdn: misplaced parenthesis in pof_handle_data()

Sekhar Nori (1):
      net: davinci emac: use dma_{map, unmap}_single API for cache coherency

Stanislaw Gruszka (3):
      bnx2x: use smp_mb() to keep ordering of read write operations
      bnx2x: remove not necessary compiler barrier
      bnx2x: change smp_mb() comment to conform the true

Steve Glendinning (2):
      smsc75xx: SMSC LAN75xx USB gigabit ethernet adapter driver
      smsc95xx: wait for PHY to complete reset during init

Tilman Schmidt (4):
      gigaset: avoid registering CAPI driver more than once
      gigaset: correct clearing of at_state strings on RING
      gigaset: prune use of tty_buffer_request_room
      gigaset: correct range checking off by one error

Vitaliy Gusev (1):
      route: Fix caught BUG_ON during rt_secret_rebuild_oneshot()

YOSHIFUJI Hideaki (3):
      bridge br_multicast: Fix handling of Max Response Code in IGMPv3 message.
      bridge br_multicast: Fix skb leakage in error path.
      bridge br_multicast: Don't refer to BR_INPUT_SKB_CB(skb)->mrouters_only without IGMP snooping.

chaithrika@ti.com (1):
      TI DaVinci EMAC: Convert to dev_pm_ops

 Documentation/networking/Makefile                  |    2 +
 Documentation/networking/timestamping/Makefile     |   11 +-
 .../networking/timestamping/timestamping.c         |   10 +-
 drivers/atm/lanai.c                                |    7 +-
 drivers/isdn/gigaset/capi.c                        |   46 +-
 drivers/isdn/gigaset/common.c                      |    6 +-
 drivers/isdn/gigaset/ev-layer.c                    |   12 +-
 drivers/isdn/gigaset/gigaset.h                     |    6 +-
 drivers/isdn/gigaset/i4l.c                         |   28 +-
 drivers/isdn/gigaset/interface.c                   |    1 -
 drivers/isdn/hardware/eicon/message.c              |   35 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c             |    6 +
 drivers/isdn/hysdn/hysdn_boot.c                    |    2 +-
 drivers/net/benet/be_cmds.c                        |    2 +-
 drivers/net/bnx2x_main.c                           |   10 +-
 drivers/net/davinci_emac.c                         |   72 +-
 drivers/net/e100.c                                 |    2 +-
 drivers/net/irda/w83977af_ir.c                     |   36 -
 drivers/net/ksz884x.c                              |    8 +-
 drivers/net/myri10ge/myri10ge.c                    |    1 -
 drivers/net/ne.c                                   |    2 +-
 drivers/net/pppol2tp.c                             |    6 +-
 drivers/net/s2io.c                                 |    4 +-
 drivers/net/usb/Kconfig                            |    8 +
 drivers/net/usb/Makefile                           |    1 +
 drivers/net/usb/hso.c                              |    3 -
 drivers/net/usb/smsc75xx.c                         | 1288 ++++++++++++++++++++
 drivers/net/usb/smsc75xx.h                         |  421 +++++++
 drivers/net/usb/smsc95xx.c                         |   15 +
 net/bridge/br_device.c                             |    2 +-
 net/bridge/br_forward.c                            |   18 +-
 net/bridge/br_input.c                              |    4 +-
 net/bridge/br_multicast.c                          |   18 +-
 net/bridge/br_private.h                            |   10 +-
 net/core/netpoll.c                                 |    4 +-
 net/dccp/ipv4.c                                    |    8 +-
 net/dccp/ipv6.c                                    |    8 +-
 net/dccp/proto.c                                   |   16 +-
 net/ipv4/route.c                                   |   16 +-
 net/phonet/pn_dev.c                                |    3 +-
 net/phonet/pn_netlink.c                            |    3 +-
 net/tipc/ref.c                                     |   26 +-
 42 files changed, 1975 insertions(+), 212 deletions(-)
 create mode 100644 drivers/net/usb/smsc75xx.c
 create mode 100644 drivers/net/usb/smsc75xx.h
