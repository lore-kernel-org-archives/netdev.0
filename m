From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 12 Nov 2010 14:38:23 -0800 (PST)
Message-ID: <20101112.143823.214225883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) mac80211 fix for handling of a scan cancellation, from Brian Cavagno=
lo

2) Minor overflow in can-bcm, from Oliver Hartkopp

3) cxgb4vf bug fixes from Casey Leedom

4) X.25 facility parsing validation bug fixes from Dan Rosenberg

5) ATM solos bug fixes from David Woodhouse.

6) TCP does state changes on unlocked socket, oops.  Based upon
   a report by Alexey Kuznetsov.

7) Don't allow socket filters to read uninitialized memory.  Based
   upon a patch by Eric Dumazet.

8) TCP_MAXSEG, if set low enough, can result in a divide by zero or
   by a negative number (because we sometimes subtract certain TCP
   option sizes), bump minimum from 8 to 64.

9) MaxBookAir3,1(2) bluetooth support, from Edgar Hucek.

10) ip_mc_drop_socket() does wrong refcounting, fix from Eric Dumazet.

11) VLAN regression fixes from Hao Zheng.

12) Link state reporting fix in virtio-net from Jason Wang.

13) ucc_geth bug fixes from Joakim Tjernlund.

14) queue_map can be used uninitialized in pktgen, from Junchang Wang.

15) axnet_cs resume fix from Ken Kawasaki.

16) Don't lose state of ipv6 addresses which will be kept across an
    ifdown/ifup cycle, fix and report from Lorenzo Colitti.

17) af_packet recvmsg() header size check is borked in the GSO case,
    fix from Mariusz Kozlowski.

18) dst cache build fix, missing linux/cache.h include, from Paul Mundt=
=2E

19) Fix from Rafael J. Wysocki for device_set_wakeup_enable() being cal=
led
    in gianfar driver from unsleepable context.

20) Fragment overlap check in ipv6 and netfilter/ipv6 is buggered, from
    Shan Wei.

21) Fix message size calculation in rtnetlink link messages, from Thoma=
s
    Graf.

22) ax25/packet ->getsockopt() info leak to userland fix from Vasiliy
    Kulikov

23) r8169 regression fixes from fran=E7ois romieu

24) Packet scheduler basic classifier doesn't report stats, fix from
    Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit 5398a64c63a69a0ac33dbae458ea4aab0dc2=
3f14:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty-2.6 (2=
010-11-08 10:55:29 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Greear (2):
      docs: Add neigh/gc_thresh3 and route/max_size documentation.
      ipv6: Warn users if maximum number of routes is reached.

Brian Cavagnolo (1):
      mac80211: unset SDATA_STATE_OFFCHANNEL when cancelling a scan

Casey Leedom (6):
      cxgb4vf: don't implement trivial (and incorrect) ndo_select_queue=
()
      cxgb4vf: fix bug in Generic Receive Offload
      cxgb4vf: fix some errors in Gather List to skb conversion
      cxgb4vf: flesh out PCI Device ID Table ...
      cxgb4vf: Fail open if link_start() fails.
      cxgb4vf: add call to Firmware to reset VF State.

Christian Lamparter (1):
      carl9170: usbid table updates

Dan Rosenberg (1):
      x25: Prevent crashing when parsing bad X.25 facilities

Daniel Drake (1):
      libertas: terminate scan when stopping interface

David S. Miller (5):
      filter: make sure filters dont read uninitialized memory
      tcp: Increase TCP_MAXSEG socket option minimum.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge git://git.kernel.org/.../kaber/nf-2.6
      tcp: Don't change unlocked socket state in tcp_v4_err().

David Woodhouse (2):
      solos: Add 'Firmware' attribute for Traverse overall firmware ver=
sion
      solos: Refuse to upgrade firmware with older FPGA. It doesn't wor=
k.

Dmitry Torokhov (1):
      NET: pktgen - fix compile warning

Edgar (gimli) Hucek (1):
      Bluetooth: Add MacBookAir3,1(2) support

Eric Dumazet (3):
      inet: fix ip_mc_drop_socket()
      net/dst: dst_dev_event() called after other notifiers
      net: avoid limits overflow

Eric Paris (1):
      netfilter: NF_HOOK_COND has wrong conditional

=46elix Fietkau (2):
      cfg80211: fix a crash in dev lookup on dump commands
      ath9k: check old power mode before clearing cycle counters

=46rank Blaschka (1):
      qeth: fix race condition during device startup

Guillaume Chazarain (2):
      skge: Remove tx queue stopping in skge_devinit()
      net: Detect and ignore netif_stop_queue() calls before register_n=
etdev()

Gustavo F. Padovan (1):
      Bluetooth: fix endianness conversion in L2CAP

Haitao Zhang (1):
      ath9k_htc: Add support for device ID 3346

Hao Zheng (3):
      vlan: Add function to retrieve EtherType from vlan packets.
      bnx2x: Look inside vlan when determining checksum proto.
      ixgbe: Look inside vlan when determining offload protocol.

Jason Wang (1):
      virtio-net: init link state correctly

Joakim Tjernlund (2):
      ucc_geth: Do not bring the whole IF down when TX failure.
      ucc_geth: Fix deadlock

Johan Hedberg (1):
      Bluetooth: Fix non-SSP auth request for HIGH security level socke=
ts

Junchang Wang (1):
      pktgen: correct uninitialized queue_map

Ken Kawasaki (1):
      axnet_cs: fix resume problem for some Ax88790 chip

Kulikov Vasiliy (1):
      net: tipc: fix information leak to userland

Linus Torvalds (1):
      libipw: fix proc entry removal

Lorenzo Colitti (1):
      ipv6: addrconf: don't remove address state on ifdown if the addre=
ss is being kept

Luiz Augusto von Dentz (1):
      Bluetooth: fix not setting security level when creating a rfcomm =
session

Mariusz Kozlowski (1):
      net: Fix header size check for GSO case in recvmsg (af_packet)

Matthew Garrett (1):
      Bluetooth: Enable USB autosuspend by default on btusb

Oliver Hartkopp (1):
      can-bcm: fix minor heap overflow

Paul Mundt (1):
      net dst: need linux/cache.h for ____cacheline_aligned_in_smp.

Pavel Emelyanov (1):
      rds: Fix rds message leak in rds_message_map_pages

Rafael J. Wysocki (1):
      gianfar: Do not call device_set_wakeup_enable() under a spinlock

Rajkumar Manoharan (3):
      ath9k: Avoid HW opmode overridden on monitor mode changes
      ath9k_htc: Fix probe failure if CONFIG_USB_DEBUG enabled
      ath9k_hw: Fix memory leak on ath9k_hw_rf_alloc_ext_banks failure

Randy Dunlap (1):
      Bluetooth: fix hidp kconfig dependency warning

Shan Wei (2):
      ipv6: fix overlap check for fragments
      netfilter: ipv6: fix overlap check for fragments

Thomas Graf (1):
      rtnetlink: Fix message size calculation for link messages

Ursula Braun (1):
      qeth: remove dev_queue_xmit invocation

Vasanthakumar Thiagarajan (1):
      ath9k_hw: Fix AR9280 surprise removal during frequent idle on/off

Vasiliy Kulikov (2):
      net: ax25: fix information leak to userland
      net: packet: fix information leak to userland

Vivek Natarajan (1):
      ath9k: Fix a DMA latency issue for Intel Pinetrail platforms.

Wey-Yi Guy (1):
      iwlwifi: dont use pci_dev before it being assign

fran=E7ois romieu (2):
      r8169: revert "Handle rxfifo errors on 8168 chips"
      r8169: fix sleeping while holding spinlock.

stephen hemminger (1):
      classifier: report statistics for basic classifier

steven miao (1):
      Bluetooth: fix unaligned access to l2cap conf data

 Documentation/networking/ip-sysctl.txt       |    9 ++
 drivers/atm/solos-attrlist.c                 |    1 +
 drivers/atm/solos-pci.c                      |    8 ++
 drivers/bluetooth/btusb.c                    |    5 +
 drivers/net/bnx2x/bnx2x_cmn.c                |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c           |   42 ++++++---
 drivers/net/cxgb4vf/sge.c                    |  122 ++++++++++++++++--=
--------
 drivers/net/cxgb4vf/t4vf_common.h            |    1 +
 drivers/net/cxgb4vf/t4vf_hw.c                |   19 ++++
 drivers/net/gianfar_ethtool.c                |    5 +-
 drivers/net/ixgbe/ixgbe_main.c               |   60 +++++++------
 drivers/net/pcmcia/axnet_cs.c                |   30 ++++--
 drivers/net/r8169.c                          |    9 +-
 drivers/net/skge.c                           |    1 -
 drivers/net/ucc_geth.c                       |   25 ++++--
 drivers/net/virtio_net.c                     |   12 ++-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c   |    3 +
 drivers/net/wireless/ath/ath9k/ath9k.h       |    1 +
 drivers/net/wireless/ath/ath9k/hif_usb.c     |   31 +++----
 drivers/net/wireless/ath/ath9k/hw.c          |   15 +++-
 drivers/net/wireless/ath/ath9k/hw.h          |    1 +
 drivers/net/wireless/ath/ath9k/init.c        |    8 ++
 drivers/net/wireless/ath/ath9k/main.c        |   29 +++++--
 drivers/net/wireless/ath/ath9k/recv.c        |    4 +-
 drivers/net/wireless/ath/ath9k/reg.h         |    1 +
 drivers/net/wireless/ath/carl9170/usb.c      |    4 +-
 drivers/net/wireless/ipw2x00/libipw_module.c |    9 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    3 +-
 drivers/net/wireless/libertas/cfg.c          |    5 +-
 drivers/net/wireless/libertas/dev.h          |    1 +
 drivers/net/wireless/libertas/main.c         |    7 ++
 drivers/s390/net/qeth_core.h                 |    9 --
 drivers/s390/net/qeth_core_main.c            |   55 ++----------
 include/linux/if_vlan.h                      |   25 +++++
 include/linux/netdevice.h                    |    5 +
 include/linux/netfilter.h                    |    2 +-
 include/net/dn.h                             |    2 +-
 include/net/dst_ops.h                        |    1 +
 include/net/sock.h                           |    4 +-
 include/net/tcp.h                            |    6 +-
 include/net/udp.h                            |    4 +-
 net/ax25/af_ax25.c                           |    2 +-
 net/bluetooth/hci_event.c                    |    6 ++
 net/bluetooth/hidp/Kconfig                   |    2 +-
 net/bluetooth/l2cap.c                        |    8 +-
 net/bluetooth/rfcomm/core.c                  |   13 ++-
 net/can/bcm.c                                |    2 +-
 net/core/dst.c                               |    1 +
 net/core/filter.c                            |   64 ++++++++------
 net/core/pktgen.c                            |    6 +-
 net/core/rtnetlink.c                         |    9 +-
 net/core/sock.c                              |   14 ++--
 net/decnet/af_decnet.c                       |    2 +-
 net/decnet/sysctl_net_decnet.c               |    4 +-
 net/ipv4/igmp.c                              |    4 +-
 net/ipv4/proc.c                              |    8 +-
 net/ipv4/sysctl_net_ipv4.c                   |    5 +-
 net/ipv4/tcp.c                               |    6 +-
 net/ipv4/tcp_input.c                         |   11 ++-
 net/ipv4/tcp_ipv4.c                          |    8 +-
 net/ipv4/udp.c                               |    4 +-
 net/ipv6/addrconf.c                          |   24 ++----
 net/ipv6/netfilter/nf_conntrack_reasm.c      |    2 +-
 net/ipv6/reassembly.c                        |    2 +-
 net/ipv6/route.c                             |    6 +-
 net/mac80211/iface.c                         |    6 +-
 net/packet/af_packet.c                       |    7 +-
 net/rds/message.c                            |    4 +-
 net/sched/cls_basic.c                        |    4 +
 net/sctp/protocol.c                          |    2 +-
 net/sctp/socket.c                            |    4 +-
 net/sctp/sysctl.c                            |    4 +-
 net/tipc/socket.c                            |    1 +
 net/wireless/nl80211.c                       |    4 +-
 net/x25/x25_facilities.c                     |   12 ++-
 75 files changed, 512 insertions(+), 335 deletions(-)
