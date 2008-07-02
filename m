From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 01 Jul 2008 20:47:21 -0700 (PDT)
Message-ID: <20080701.204721.57016319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752465AbYGBDrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 23:47:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Lots of small fixers all over, highlights:

1) Kernel command line net device name parsing potential overflow.
   Fix from Wang Chen.

2) Fix incomplete conversion over to RT6_LOOKUP_F_* flags in ipv6.
   From YOSHIFUJI Hideaki.

3) Accidental positive errno usage in packet scheduler.

4) poll() semantic fix for AF_UNIX sockets on connected datagram
   sockets.  From Rainer Weikusat.

5) Race fix in ipv4/ipv6 fragmentation code, from Pavel Emelyanov.

6) Fix possible double free in packet scheduler filter list destruction,
   from Patrick McHardy.

7) TCP mem[] sysctls computed considering highmem, which is wrong.
   From Miquel van Smoorenburg.

8) skb->ip_summed setting is made incorrectly when LRO is not possible.
   Fix from Eli Cohen.

9) The usual assortment of driver bug fixes via Jeff Garzik and
   John Linville.

Please pull, thanks a lot!

The following changes since commit b9f75f45a6b46a0ab4eb0857d437a0845871f314:
  Eric W. Biederman (1):
        netns: Don't receive new packets in a dead network namespace.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (2):
      pkt_sched: Remove CONFIG_NET_SCH_RR
      include/linux/netdevice.h: don't export MAX_HEADER to userspace

Al Viro (1):
      [netdrvr] netxen: fix netxen_pci_tbl[] breakage

Andi Kleen (1):
      [netdrvr] Fix IOMMU overflow checking in s2io.c

Andre Haupt (1):
      hamradio: remove unused variable

Andy Gospodarek (1):
      e1000: only enable TSO6 via ethtool when using correct hardware

Atsushi Nemoto (2):
      tc35815: Mark carrier-off before starting PHY
      tc35815: Fix receiver hangup on Rx FIFO overflow

Ben Hutchings (2):
      qla3xxx: Hold RTNL while calling dev_close()
      Hold RTNL while calling dev_close()

David S. Miller (2):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6

Eli Cohen (1):
      net/inet_lro: remove setting skb->ip_summed when not LRO-able

Emmanuel Grumbach (2):
      mac80211: fix an oops in several failure paths in key allocation
      mac80211: don't accept WEP keys other than WEP40 and WEP104

Harvey Harrison (1):
      prism: islpci_eth.c endianness fix

Ingo Molnar (1):
      [netdrvr] 3c59x: remove irqs_disabled warning from local_bh_enable

Ivo van Doorn (2):
      rt2x00: Fix unbalanced mutex locking
      rt2x00: Fix lock dependency errror

Jeff Kirsher (2):
      igb: fix EEH recovery during reset on PPC
      e1000e: fix EEH recovery during reset on PPC

Joonwoo Park (1):
      textsearch: fix Boyer-Moore text search bug

Jozsef Kadlecsik (1):
      netfilter: nf_conntrack_tcp: fixing to check the lower bound of valid ACK

Julia Lawall (1):
      drivers/net/r6040.c: Eliminate double sizeof

Julius Volz (1):
      netlink: Fix some doc comments in net/netlink/attr.c

Kevin Hao (1):
      e100: Do pci_dma_sync after skb_alloc for proper operation on ixp4xx

Komuro (1):
      pcnet_cs, axnet_cs: clear bogus interrupt before request_irq

Li Zefan (1):
      CONNECTOR: add a proc entry to list connectors

Michael Buesch (4):
      b43: Do not return TX_BUSY from op_tx
      b43legacy: Do not return TX_BUSY from op_tx
      b43: Fix possible MMIO access while device is down
      b43legacy: Fix possible NULL pointer dereference in DMA code

Michal Schmidt (1):
      s2io: fix documentation about intr_type

Miquel van Smoorenburg (1):
      tcp: calculate tcp_mem based on low memory instead of all memory

Octavian Purdila (1):
      tcp: fix for splice receive when used with software LRO

Patrick McHardy (4):
      netfilter: ip6table_mangle: don't reroute in LOCAL_IN
      net-sched: change tcf_destroy_chain() to clear start of filter list
      net-sched: fix filter destruction in atm/hfsc qdisc destruction
      net: fib_rules: fix error code for unsupported families

Paul Larson (1):
      ixgbe: fix EEH recovery during reset on PPC

Paul Moore (1):
      netlabel: Fix a problem when dumping the default IPv6 static labels

Pavel Emelyanov (1):
      inet fragments: fix race between inet_frag_find and inet_frag_secret_rebuild

Pavel Roskin (2):
      hostap: don't report useless WDS frames by default
      hostap: fix sparse warnings

Pekka Enberg (2):
      ipg: fix jumbo frame compilation
      ipg: use NULL, not zero, for pointers

Rainer Weikusat (1):
      af_unix: fix 'poll for write'/connected DGRAM sockets

Ron Rindjunsky (1):
      iwlwifi: improve scanning band selection management

Stephen Hemminger (2):
      tcp: /proc/net/tcp rto,ato values not scaled properly (v2)
      ipv4: fix sysctl documentation of time related values

Tony Vroon (1):
      mac80211: implement EU regulatory domain

WANG Cong (1):
      pkt_sched: ERR_PTR() ususally encodes an negative errno, not positive.

Wang Chen (4):
      netdevice: Fix typo of dev_unicast_add() comment
      netlink: Unneeded local variable
      net: Tyop of sk_filter() comment
      netdevice: Fix wrong string handle in kernel command line parsing

YOSHIFUJI Hideaki (1):
      ipv6 route: Convert rt6_device_match() to use RT6_LOOKUP_F_xxx flags.

 Documentation/networking/ip-sysctl.txt        |   12 ++----
 Documentation/networking/s2io.txt             |    6 +-
 drivers/connector/connector.c                 |   40 +++++++++++++++++++
 drivers/net/3c59x.c                           |    5 +-
 drivers/net/e100.c                            |    2 +
 drivers/net/e1000/e1000_ethtool.c             |    2 +-
 drivers/net/e1000e/netdev.c                   |    3 +-
 drivers/net/hamradio/dmascc.c                 |    2 -
 drivers/net/igb/igb_main.c                    |    3 +-
 drivers/net/ipg.c                             |   16 ++++----
 drivers/net/ixgbe/ixgbe_main.c                |    3 +-
 drivers/net/netxen/netxen_nic_main.c          |   18 +++++---
 drivers/net/pcmcia/axnet_cs.c                 |    2 +
 drivers/net/pcmcia/pcnet_cs.c                 |    3 +
 drivers/net/qla3xxx.c                         |    2 +
 drivers/net/r6040.c                           |    2 +-
 drivers/net/s2io.c                            |   35 ++++++-----------
 drivers/net/s2io.h                            |    4 --
 drivers/net/tc35815.c                         |    4 +-
 drivers/net/wan/x25_asy.c                     |    3 +
 drivers/net/wireless/b43/leds.c               |    3 +
 drivers/net/wireless/b43/main.c               |   12 ++++--
 drivers/net/wireless/b43legacy/dma.c          |    2 +-
 drivers/net/wireless/b43legacy/main.c         |    6 ++-
 drivers/net/wireless/hostap/hostap_80211_rx.c |    8 ++--
 drivers/net/wireless/hostap/hostap_ap.c       |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c       |    8 ++--
 drivers/net/wireless/hostap/hostap_hw.c       |   10 ++--
 drivers/net/wireless/hostap/hostap_main.c     |    5 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   33 +++++++++-------
 drivers/net/wireless/iwlwifi/iwl4965-base.c   |   39 ++++++++++---------
 drivers/net/wireless/prism54/islpci_eth.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c       |   36 ++++++++++-------
 drivers/net/wireless/rt2x00/rt2x00.h          |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c       |   38 ++++++++++++------
 drivers/net/wireless/rt2x00/rt2x00mac.c       |    4 +-
 drivers/net/wireless/rt2x00/rt73usb.c         |   36 ++++++++++-------
 include/linux/inet_lro.h                      |    6 ++-
 include/linux/netdevice.h                     |    4 ++
 include/net/mac80211.h                        |    9 ++++
 include/net/sch_generic.h                     |    2 +-
 lib/ts_bm.c                                   |    2 +-
 net/core/dev.c                                |    6 +-
 net/core/fib_rules.c                          |    4 +-
 net/core/filter.c                             |    1 -
 net/core/skbuff.c                             |   17 ++++++--
 net/ipv4/inet_fragment.c                      |   16 +++++--
 net/ipv4/inet_lro.c                           |    3 +-
 net/ipv4/ip_fragment.c                        |    2 +
 net/ipv4/tcp.c                                |    9 +++-
 net/ipv4/tcp_ipv4.c                           |    6 +-
 net/ipv6/netfilter/ip6table_mangle.c          |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c       |    3 +-
 net/ipv6/reassembly.c                         |    2 +
 net/ipv6/route.c                              |    6 +-
 net/ipv6/tcp_ipv6.c                           |    6 +-
 net/mac80211/key.c                            |    9 ++++
 net/mac80211/wext.c                           |    7 +++
 net/mac80211/wme.c                            |    3 +-
 net/netfilter/nf_conntrack_proto_tcp.c        |   13 +++---
 net/netlabel/netlabel_unlabeled.c             |    2 +-
 net/netlink/af_netlink.c                      |    2 +-
 net/netlink/attr.c                            |    7 ++-
 net/sched/Kconfig                             |   11 -----
 net/sched/sch_api.c                           |    6 +-
 net/sched/sch_atm.c                           |    7 ++-
 net/sched/sch_cbq.c                           |    8 +--
 net/sched/sch_dsmark.c                        |    2 +-
 net/sched/sch_generic.c                       |    2 +-
 net/sched/sch_hfsc.c                          |    6 ++-
 net/sched/sch_htb.c                           |    4 +-
 net/sched/sch_ingress.c                       |    2 +-
 net/sched/sch_prio.c                          |    2 +-
 net/sched/sch_sfq.c                           |    2 +-
 net/unix/af_unix.c                            |   52 +++++++++++-------------
 net/wireless/reg.c                            |   18 +++++++++
 76 files changed, 411 insertions(+), 272 deletions(-)
