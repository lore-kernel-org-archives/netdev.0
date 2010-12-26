From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 25 Dec 2010 20:33:01 -0800 (PST)
Message-ID: <20101225.203301.183053493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Locally generated ipv6 ipsec tunnel packets need to be fragmented
   properly.  Fix from David Stevens.

2) Various cases of bonding over vlan aren't handled properly and can
   crash, fixes from Ben Hutchings.

3) Revert an optimization in the packet scheduler, wherein we tried to
   share an skb instead of fully cloning it, to fix some regressions.
   From Changli Gao.

4) tehuti firmware filename string was wrong, from Ben Hutchings.

5) Allot handling in sfq packet scheduler was incorrect, fix from
   Eric Dumazet.

6) Several drivers skb_reserve(skb, 2) but forget to incorporate
   that reserved space in their allocations, leading to corruption
   of memory past the end of the SKB data area later.  Fixed by
   Jarek Poplawski.

7) Packet checksumming fix in veth, from Micha=A9=A9 Miros=A9=A9aw.

8) Fix hash list corruption in sk_prot_alloc(), from Octavian Purdila.

9) A few bluetooth fixes:
   a) Fix security level setting in RFCOMM, from Johan Hedberg.
   b) Missing NULL check in HCI ldisc, from Jun Nie.

10) Wireless fixes:
    a) Correct iwlagn eeprom layout assumptions, from Johannes Berg.
    b) Fix NULL deref in libertas channel handling, from Sven Neumann.
    c) mac80211 ibss merge NULL derer fix, from Tim Harvey.
    d) Add some USB IDs to p54usb driver, from Christian Lamparter.
    e) Fix workqueu issue during suspend in mac80211, from Herton Ronal=
do Krzesinski.
    f) mac80211 mesh mis-handled skb clone failure, from Johannes Berg.

11) PMTU handling doesn't flush existing route correctly in ipv6, fix
    from Andrey Vagin.

12) benet drivers needs to use mutex instead of spinlock, fix from Ivan=
 Vecera.

13) Don't use legacy PCI PM in atl1c driver, from Rafael J. Wysocki.

14) Bug in TCP's listening_get_next() can cause /proc/net/tcp listings
    to loop forever.  Fix from Eric Dumazet.

15) Fix underflow in irda IRLMP_ENUMDEVICES ioctl() handlng, fix from
    Dan Rosenberg.

16) Revert a 2.6.37 change for ipv4 subnet handling that causes
    regressions.

17) Don't accidently create ipv4 routes on downed devices, fix from
    Eric Dumazet.

Please pull, thanks a lot!   =20

The following changes since commit d3c7e1ab043abd7706db4fbccf327df9e62f=
7990:

  Merge branch 'merge' of git://git.secretlab.ca/git/linux-2.6 (2010-12=
-24 13:00:37 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andreas Mohr (1):
      net: Add USB PID for new MOSCHIP USB ethernet controller MCS7832 =
variant

Andrey Vagin (1):
      ipv6: delete expired route in ip6_pmtu_deliver

Arnaud Ebalard (1):
      asix: add USB ID for Logitec LAN-GTJ U2A

Ben Hutchings (4):
      bonding/vlan: Remove redundant VLAN tag insertion logic
      bonding: Change active slave quietly when bond is down
      bonding/vlan: Fix mangled NAs on slaves without VLAN tag insertio=
n
      tehuti: Firmware filename is tehuti/bdx.bin

Changli Gao (1):
      net_sched: always clone skbs

Christian Lamparter (1):
      p54usb: add 5 more USBIDs

Dan Carpenter (2):
      typhoon: memory corruption in typhoon_get_drvinfo()
      USB: mcs7830: return negative if auto negotiate fails

Dan Rosenberg (1):
      irda: prevent integer underflow in IRLMP_ENUMDEVICES

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      net: Fix range checks in tcf_valid_offset().
      Merge branch 'master' of ssh://master.kernel.org/.../linville/wir=
eless-2.6
      Revert "ipv4: Allow configuring subnets as local addresses"

David Stevens (2):
      bridge: fix IPv6 queries for bridge multicast snooping
      ipv6: Fragment locally generated tunnel-mode IPSec6 packets as ne=
eded.

Dmitry V. Levin (1):
      netlink: fix gcc -Wconversion compilation warning

Don Fry (1):
      MAINTAINERS: email address change

Eduardo Costa (1):
      p54usb: New USB ID for Gemtek WUBI-100GW

Eric Dumazet (3):
      net_sched: sch_sfq: fix allot handling
      tcp: fix listening_get_next()
      ipv4: dont create routes on down devices

Herton Ronaldo Krzesinski (1):
      mac80211: avoid calling ieee80211_work_work unconditionally

Hillf Danton (1):
      bonding: Fix slave selection bug.

Ivan Vecera (1):
      be2net: use mutex instead of spin lock for mbox_lock

Jarek Poplawski (2):
      sundance: Fix oopses with corrupted skb_shared_info
      epic100: hamachi: yellowfin: Fix skb allocation size

Johan Hedberg (1):
      Bluetooth: Fix initial RFCOMM DLC security level

Johannes Berg (2):
      iwlagn: rename enhanced txpower fields
      mac80211: fix mesh forwarding

Johannes Stezenbach (1):
      mac80211/rt2x00: add ieee80211_tx_status_ni()

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6

Jun Nie (1):
      Bluetooth: add NULL pointer check in HCI

Ken Kawasaki (1):
      axnet_cs: move id (0x1bf, 0x2328) to axnet_cs

Meelis Roos (1):
      hostap: remove netif_stop_queue from init

Micha=A9=A9 Miros=A9=A9aw (1):
      net/veth: Fix packet checksumming

Octavian Purdila (1):
      net: fix nulls list corruptions in sk_prot_alloc

Rafael J. Wysocki (1):
      atl1c: Do not use legacy PCI power management

Sven Neumann (1):
      libertas: fix potential NULL-pointer dereference

Tim Harvey (1):
      mac80211: Fix NULL-pointer deference on ibss merge when not ready

Wei Yongjun (1):
      sctp: fix the return value of getting the sctp partial delivery p=
oint

Wey-Yi Guy (1):
      iwlagn: implement layout-agnostic EEPROM reading

stephen hemminger (1):
      ipv6: don't flush routes when setting loopback down

 MAINTAINERS                                   |    2 +-
 drivers/bluetooth/hci_ldisc.c                 |    6 +-
 drivers/net/atl1c/atl1c_main.c                |   39 ++++-------
 drivers/net/benet/be.h                        |    2 +-
 drivers/net/benet/be_cmds.c                   |   75 +++++++++++++----=
-----
 drivers/net/benet/be_main.c                   |    2 +-
 drivers/net/bonding/bond_ipv6.c               |    7 ++-
 drivers/net/bonding/bond_main.c               |   42 +++---------
 drivers/net/bonding/bonding.h                 |    4 +-
 drivers/net/epic100.c                         |    4 +-
 drivers/net/hamachi.c                         |    4 +-
 drivers/net/pcmcia/axnet_cs.c                 |    1 +
 drivers/net/pcmcia/pcnet_cs.c                 |    1 -
 drivers/net/sundance.c                        |    4 +-
 drivers/net/tehuti.c                          |    4 +-
 drivers/net/typhoon.c                         |    1 -
 drivers/net/usb/asix.c                        |    4 +
 drivers/net/usb/mcs7830.c                     |   14 +++-
 drivers/net/veth.c                            |    4 +-
 drivers/net/wireless/hostap/hostap_main.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    2 +
 drivers/net/wireless/iwlwifi/iwl-6000.c       |   12 ++++
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c |   88 +++++++++++++++++=
+++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c    |    6 ++
 drivers/net/wireless/iwlwifi/iwl-core.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h     |   25 ++++++-
 drivers/net/wireless/libertas/cfg.c           |    2 +-
 drivers/net/wireless/p54/p54usb.c             |    6 ++
 drivers/net/wireless/rt2x00/rt2800pci.c       |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h          |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c       |    9 ++-
 drivers/net/yellowfin.c                       |    4 +-
 include/linux/netlink.h                       |    2 +-
 include/net/flow.h                            |    1 -
 include/net/ip6_route.h                       |   10 +++
 include/net/mac80211.h                        |   28 +++++++-
 include/net/pkt_cls.h                         |    4 +-
 include/net/sch_generic.h                     |    6 +--
 include/net/sock.h                            |    3 +
 net/bluetooth/rfcomm/core.c                   |    1 +
 net/bridge/br_multicast.c                     |    2 +-
 net/core/fib_rules.c                          |    3 +-
 net/core/sock.c                               |   47 ++++++++++----
 net/ipv4/fib_frontend.c                       |   10 ++-
 net/ipv4/route.c                              |    7 +-
 net/ipv4/tcp_ipv4.c                           |    4 +-
 net/ipv4/udp.c                                |    1 +
 net/ipv4/udplite.c                            |    1 +
 net/ipv6/addrconf.c                           |    4 +-
 net/ipv6/ip6_output.c                         |   12 +---
 net/ipv6/route.c                              |    7 ++-
 net/ipv6/udp.c                                |    1 +
 net/ipv6/udplite.c                            |    1 +
 net/ipv6/xfrm6_output.c                       |   16 ++++-
 net/irda/af_irda.c                            |   18 +++--
 net/mac80211/ibss.c                           |    4 +
 net/mac80211/rx.c                             |    5 +-
 net/mac80211/work.c                           |    5 +-
 net/sched/sch_sfq.c                           |   20 ++----
 net/sctp/socket.c                             |    2 +-
 60 files changed, 413 insertions(+), 190 deletions(-)
