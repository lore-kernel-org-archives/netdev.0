From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 04 Feb 2011 13:18:28 -0800 (PST)
Message-ID: <20110204.131828.183039007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Lots of little fixes in here, as is usually the case at this point.

The qeth fixes and the XEN netfront buggy guest handling are the
largest changes, with the ipv4/ipv6 multicast compat ioctl handling
bits next in terms of size.

1) Missing ref grab in netfilter conntrack netlink, from Pablo Neira Ay=
uso.
2) IPV6 boundary checks busted in xt_iprange module, from Thomas Jacob.
3) Wrong indexes used in loop in batman-adv module, leading to crash, f=
ix
   from Linus L=FCssing.
4) rtlwifi refactoring caused regressions in firmware upload, fix from
   Chaoming Li.
5) Fix error handling in ath5k_hw_dma_stop, from Bob Copeland.
6) Frame endianness fixes in ath5k, also from Bob Copeland.
7) Fix crashes due to ath9k tasklet shutdown races, from Stanislaw Grus=
zka.
8) Fix build warnings in econet, from Eric Dumazet.
9) Handle buggy guests setting of NETRX_csum_* in XEN netfront driver, =
from
   Ian Campbell.
10) Fix DMA-API debugging message spew in dl2k driver due to double
    unmaps.  Fix from Stanislaw Gruszka.
11) In rtnetlink, validate_linkmsg() uses wrong afinfo pointer.  Fix
    from Kurt Van Dijck.
12) __alloc_skb() needs kmemcheck annotations to avoid false positives,
    from Eric Dumazet.
13) Remove some complications wrt. ipv6 inetpeer binding.  All reports
    about triggered warnings et al. should be gone now.
14) napi_reuse_skb() must reset skb->dev and skb->iif, from Herbert Xu
    and Andy Gospodarek.
15) CAIF protocol headers need userspace export.  From Sjur Braendeland=
=2E
16) Fix oops on adding network namespace, fix from Eric W. Biederman.
17) ipv4 and ipv6 multicast ioctls need compat handling.  Based upon
    some initial work by Eric W. Biederman and some audits by Arnd
    Bergmann.
18) batman-adv module unhashes wrong object on failures, fix from
    Sven Eckelmann.
19) batman-adv forgets to free memory in free_info(), also from Sven.
20) batman-adv list traversal in send_vis_packets() drops lock inside
    it's loop, so we have to iterate over the head to be thread safe.
    Also from Sven Eckelmann.
21) bnx2x driver fixes from Yaniv Rosner and Eilon Greenstein.
22) wl12xx wireless has use-after-free error, fix from Mathias Krause.
23) Fix OOPS regression with IPSEC, ipv4/ipv6 blackhole dst ops need
    to implement a "default_mtu" method.  Fix from Roland Dreier.
24) CAN softing driver needs to depend upon IOMEM.
25) get_rps_cpu() erroneously elides flow processing when RPS map has
    length of one.  Fix from Tom Herbert.
26) ipv6 unregisters sysctl tables in wrong order, resulting in
    WARNING in unregister_sysctl_table().  Fix from Eric W. Biederman.
27) enc28j60 driver uses "sizeof(pointer)" when it means "sizeof(array)=
",
    fix from Stefan Weil.
28) vhost spews bogus RCU warnings, fix from Micahel S. Tsirkin.
29) arpt_mangle.c's checkentry() was changed to return int, but it
    still erroneously returns "false" and "true".  Fix from Pable
    Neira Ayuso.
30) Fix netfilter conntrack event filtering, also from Pablo.
31) SKB leak in ath_paprd_send_frame(), fix from Mohammed Shafi Shajakh=
an.
32) Mixed up boolean operators in vxge driver result in condition
    always true, fix from Stefan Weil.
33) Remove use of undefined operation in depca driver, from Alan Cox.
34) ISDN icn driver strncpy() usage fix, from Stefan Weil.
35) be2net driver erroneously mucks with tx queue status during link
    up/down, resulting in crashes.  Fix from Ajit Khaparde.
36) be2net illegally calls netif_stop_queue() before register_netdevice=
()
    happens, also from Ajit.
37) s390 qeth fixes from Ursula Braun, Frank Blaschka, and Stefan Weil.
38) Fix races between interface up/down and get_stats in NIU driver.
39) Like nlmsg_cancel(), genlmsg_cancel() must explicitly handle NULL
    second argument (before we subtract from it and it no longer
    looks like "NULL").  Analysis and fix from Julia Lawall.
40) R8169 bug fixes via Francois Romieu:
    a) 8168c needs RxFIFO overflow workaround too, from Ivan Vecera.
    b) Refine RxFIFO overflow logic to reset less, from Francois.
    c) Interrupt handler needs to be more careful in RxFIFO overflow
       cases, also from Francois.
41) Bridging code inserts FDB entries to the hash table before they
    are fully initialized.  Since FDB lookup uses RCU this is a serious
    issue, from Pavel Emelyanov.
42) Some CAN drivers create world-writable sysfs files, oops.  Fix from
    Vasiliy Kulikov.

Please pull, thanks a lot!

The following changes since commit 831d52bc153971b70e64eccfbed2b232394f=
22f8:

  x86, mm: avoid possible bogus tlb entries by clearing prev mm_cpumask=
 after switching mm (2011-02-03 13:32:39 -0800)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (3):
      be2net: fix a crash seen during insmod/rmmod test
      be2net: remove netif_stop_queue being called before register_netd=
ev.
      MAINTAINERS: update email ids of the be2net driver maintainers.

Alan Cox (1):
      depca: Fix warnings

Andy Gospodarek (1):
      gro: reset skb_iif on reuse

Bob Copeland (2):
      ath5k: fix error handling in ath5k_hw_dma_stop
      ath5k: correct endianness of frame duration

Chaoming Li (1):
      rtlwifi: Fix firmware upload errors

Chuck Ebbert (2):
      CAN: softing driver depends on IOMEM
      atl1c: Add missing PCI device ID

David S. Miller (9):
      ipv6: Remove route peer binding assertions.
      Merge branch 'batman-adv/merge-oopsonly' of git://git.open-mesh.o=
rg/ecsv/linux-merge
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      niu: Fix races between up/down and get_stats.
      net: Fix bug in compat SIOCGETSGCNT handling.
      net: Support compat SIOCGETVIFCNT ioctl in ipv4.
      net: Provide compat support for SIOCGETMIFCNT_IN6 and SIOCGETSGCN=
T_IN6.

Eric Dumazet (2):
      econet: remove compiler warnings
      net: add kmemcheck annotation in __alloc_skb()

Eric W. Biederman (3):
      net: Fix ip link add netns oops
      net: Add compat ioctl support for the ipv4 multicast ioctl SIOCGE=
TSGCNT
      net: Fix ipv6 neighbour unregister_sysctl_table warning

=46rancois Romieu (2):
      r8169: RxFIFO overflow oddities with 8168 chipsets.
      r8169: prevent RxFIFO induced loops in the irq handler.

=46rank Blaschka (1):
      qeth: add more strict MTU checking

Herbert Xu (1):
      gro: Reset dev pointer on reuse

Ian Campbell (1):
      xen: netfront: handle incoming GSO SKBs which are not CHECKSUM_PA=
RTIAL

Ivan Vecera (1):
      r8169: use RxFIFO overflow workaround for 8168c chipset.

Julia Lawall (1):
      include/net/genetlink.h: Allow genlmsg_cancel to accept a NULL ar=
gument

Ken Kawasaki (1):
      axnet_cs: reduce delay time at ei_rx_overrun

Kurt Van Dijck (1):
      net: fix validate_link_af in rtnetlink core

Linus L=FCssing (1):
      batman-adv: Fix kernel panic when fetching vis data on a vis serv=
er

Luciano Coelho (1):
      MAINTAINERS: update information for the wl12xx driver

Mathias Krause (1):
      wl12xx: fix use after free

Michael S. Tsirkin (1):
      vhost: rcu annotation fixup

Mohammed Shafi Shajakhan (1):
      ath9k: Fix memory leak due to failed PAPRD frames

Oliver Hartkopp (1):
      slcan: fix referenced website in Kconfig help text

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: fix missing refcount increment during dumps
      netfilter: arpt_mangle: fix return values of checkentry
      netfilter: ecache: always set events bits, filter them later

Pavel Emelyanov (1):
      bridge: Don't put partly initialized fdb into hash

Peter Chubb (1):
      tcp_ecn is an integer not a boolean

Rajkumar Manoharan (2):
      ath9k_hw: Fix system hang when resuming from S3/S4
      ath9k: Fix power save usage count imbalance on deinit

Roland Dreier (1):
      net: Add default_mtu() methods to blackhole dst_ops

Stanislaw Gruszka (3):
      ath9k: fix race conditions when stop device
      ath9k_htc: fix race conditions when stop device
      dl2k: nulify fraginfo after unmap

Stefan Weil (5):
      enc28j60: Fix reading of transmit status vector
      vxge: Fix wrong boolean operator
      isdn: icn: Fix potentially wrong string handling
      s390: Fix wrong size in memcmp (netiucv)
      s390: Fix possibly wrong size in strncmp (smsgiucv)

Sven Eckelmann (3):
      batman-adv: Remove vis info on hashing errors
      batman-adv: Remove vis info element in free_info
      batman-adv: Make vis info stack traversal threadsafe

Thomas Jacob (1):
      netfilter: xt_iprange: Incorrect xt_iprange boundary check for IP=
v6

Tom Herbert (1):
      net: Check rps_flow_table when RPS map length is 1

Ursula Braun (3):
      qeth: show new mac-address if its setting fails
      qeth: allow HiperSockets framesize change in suspend
      qeth: allow OSA CHPARM change in suspend state

Vasiliy Kulikov (2):
      net: can: at91_can: world-writable sysfs files
      net: can: janz-ican3: world-writable sysfs termination file

Vladislav Zolotarov (1):
      bnx2x: multicasts in NPAR mode

Yaniv Rosner (5):
      bnx2x: Remove setting XAUI low-power for BCM8073
      bnx2x: Fix LED blink rate on BCM84823
      bnx2x: Fix port swap for BCM8073
      bnx2x: Fix potential link loss in multi-function mode
      bnx2x: Update bnx2x version to 1.62.00-5

sjur.brandeland@stericsson.com (1):
      caif: bugfix - add caif headers for userspace usage.

 Documentation/networking/ip-sysctl.txt        |    2 +-
 MAINTAINERS                                   |   15 +--
 drivers/isdn/icn/icn.c                        |    3 +-
 drivers/net/atl1c/atl1c_main.c                |    1 +
 drivers/net/benet/be_main.c                   |    4 -
 drivers/net/bnx2x/bnx2x.h                     |    4 +-
 drivers/net/bnx2x/bnx2x_link.c                |   65 +++--------
 drivers/net/bnx2x/bnx2x_main.c                |   27 ++---
 drivers/net/can/Kconfig                       |    2 +-
 drivers/net/can/at91_can.c                    |    2 +-
 drivers/net/can/janz-ican3.c                  |    2 +-
 drivers/net/can/softing/Kconfig               |    2 +-
 drivers/net/depca.c                           |    6 +-
 drivers/net/dl2k.c                            |    4 +-
 drivers/net/enc28j60.c                        |    2 +-
 drivers/net/niu.c                             |   61 ++++++++---
 drivers/net/pcmcia/axnet_cs.c                 |    6 +-
 drivers/net/r8169.c                           |   41 ++++++--
 drivers/net/vxge/vxge-config.c                |    2 +-
 drivers/net/wireless/ath/ath5k/dma.c          |    4 +-
 drivers/net/wireless/ath/ath5k/pcu.c          |    4 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c    |    3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    3 -
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |   21 +++-
 drivers/net/wireless/ath/ath9k/init.c         |    7 +-
 drivers/net/wireless/ath/ath9k/main.c         |   19 +++-
 drivers/net/wireless/rtlwifi/efuse.c          |   40 ++++----
 drivers/net/wireless/wl12xx/spi.c             |    3 +-
 drivers/net/xen-netfront.c                    |   96 +++++++++++++++--
 drivers/s390/net/netiucv.c                    |    2 +-
 drivers/s390/net/qeth_core_main.c             |  149 +++++++++++++----=
--------
 drivers/s390/net/qeth_l2_main.c               |    4 +-
 drivers/s390/net/smsgiucv.c                   |    2 +-
 drivers/vhost/net.c                           |    9 +-
 drivers/vhost/vhost.h                         |    6 +-
 include/linux/Kbuild                          |    1 +
 include/linux/caif/Kbuild                     |    2 +
 include/linux/mroute.h                        |    1 +
 include/linux/mroute6.h                       |    1 +
 include/net/genetlink.h                       |    3 +-
 include/net/netfilter/nf_conntrack_ecache.h   |    3 -
 include/net/sock.h                            |    2 +
 net/batman-adv/vis.c                          |   14 ++-
 net/bridge/br_fdb.c                           |    4 +-
 net/core/dev.c                                |    5 +-
 net/core/rtnetlink.c                          |    6 +-
 net/core/skbuff.c                             |    1 +
 net/econet/af_econet.c                        |    4 +-
 net/ipv4/af_inet.c                            |   16 +++
 net/ipv4/ipmr.c                               |   76 +++++++++++++
 net/ipv4/netfilter/arpt_mangle.c              |    6 +-
 net/ipv4/raw.c                                |   19 +++
 net/ipv4/route.c                              |    6 +
 net/ipv6/ip6mr.c                              |   75 +++++++++++++
 net/ipv6/raw.c                                |   19 +++
 net/ipv6/route.c                              |   10 +-
 net/ipv6/sysctl_net_ipv6.c                    |    9 ++-
 net/netfilter/nf_conntrack_ecache.c           |    3 +
 net/netfilter/nf_conntrack_netlink.c          |    1 +
 net/netfilter/xt_iprange.c                    |   16 +--
 60 files changed, 637 insertions(+), 289 deletions(-)
 create mode 100644 include/linux/caif/Kbuild
