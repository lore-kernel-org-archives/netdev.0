From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 11 Jun 2011 21:01:08 -0700 (PDT)
Message-ID: <20110611.210108.2071515542406111065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab1FLECj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 00:02:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Memory leak in ISDN hfcsusb driver, from Jesper Juhl.
2) Network device leak in netpoll setup, from Dan Carpenter
3) Fix error handling in get_net_ns_by_fd() and sanitize error
   return values of l2tp_dfs_seq_open(), from Al Viro.
4) Bridge netfilter fake rtable ops needs cow_metrics handler, otherwis=
e
   we OOPS, from Alexander Holler.
5) Endianness fix in dl2k EEPROM code from Daniel Hellstrom.
6) Signedness fix in ip{,6}_queue from Dave Jones.
7) Mark lockdep classes in IRDA properly.
8) Prevent kernel stack data leak in af_packet, from Eric Dumazet.
9) ep93xx_eth DMA et al. fixes from Mika Westerberg.
10) Bonding screws up TX queue selection on the way down to physical
    device, save and restore it properly, from Neil HOrman.
11) Fix conntrack ct leak in l4proto->error(), from Pablo Neira Ayuso.
12) am79c961 fixes from Russell King
13) Channel switch locking fixes in ilwagn from Stanislaw Gruszka.
14) IPSEC replay handling has off-by-one error, from Steffen Klassert.
15) gianfar filter table needs to be per-device, from Wu Jiajun-B06378.
16) Turn off ath5k fast channel switching by default, causes problems
    for some people.  From Nick Kossifidis.
17) CPU offlining can stall packet processing, fix from Heiko Carstens.

Please pull, thanks a lot!

The following changes since commit b99ca60c83a631adaba9c2fff8f2dd14d351=
7a61:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/jmorris/security-testing-2.6 (2011-06-11 19:56:25 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Al Viro (2):
      get_net_ns_by_fd() oopses if proc_ns_fget() returns an error
      fix return values of l2tp_dfs_seq_open()

Alexander Holler (1):
      bridge: provide a cow_metrics method for fake_ops

Anirban Chakraborty (1):
      qlcnic: Fix bug in FW queue dump

Dan Carpenter (1):
      netpoll: call dev_put() on error in netpoll_setup()

Daniel Drake (1):
      libertas_sdio: handle spurious interrupts

Daniel Hellstrom (1):
      dl2k: EEPROM CRC calculation wrong endianess on bigendian machine

Dave Jones (1):
      netfilter: use unsigned variables for packet lengths in ip[6]_que=
ue.

David S. Miller (4):
      Merge branch 'pablo/nf-2.6-updates' of git://1984.lsi.us.es/net-2=
=2E6
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless-2.6
      net: Rework netdev_drivername() to avoid warning.
      irda: iriap: Use seperate lockdep class for irias_objects->hb_spi=
nlock

Eric Dumazet (3):
      netfilter: add more values to enum ip_conntrack_info
      af_packet: prevent information leak
      net: pmtu_expires fixes

Grant Likely (1):
      net: fix smc91x.c device tree support

H Hartley Sweeten (1):
      ep93xx_eth: Update MAINTAINERS

Heiko Carstens (1):
      net: cpu offline cause napi stall

Jesper Juhl (1):
      ISDN, hfcsusb: Don't leak in hfcsusb_ph_info()

Jiri Pirko (1):
      vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check

Johannes Berg (1):
      mac80211: fix IBSS teardown race

John W. Linville (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into for-davem
      Revert "mac80211: Skip tailroom reservation for full HW-crypto de=
vices"
      Revert "mac80211: stop queues before rate control updation"
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into for-davem

Jozsef Kadlecsik (2):
      netfilter: ipset: Fix return code for destroy when sets are in us=
e
      netfilter: ipset: Use the stored first cidr value instead of '1'

Julian Anastasov (2):
      ipvs: restore support for iptables SNAT
      netfilter: nf_nat: fix crash in nf_nat_csum

Luciano Coelho (1):
      nl80211: fix overflow in ssid_len

Marcus Meissner (1):
      net/ipv6: check for mistakenly passed in non-AF_INET6 sockaddrs

Mika Westerberg (5):
      ep93xx: set DMA masks for the ep93xx_eth
      net: ep93xx_eth: pass struct device to DMA API functions
      net: ep93xx_eth: allocate buffers using kmalloc()
      net: ep93xx_eth: drop GFP_DMA from call to dma_alloc_coherent()
      net: ep93xx_eth: fix DMA API violations

Mike McCormack (2):
      rtlwifi: Fix logic in rx_interrupt
      rtlwifi: Avoid modifying skbs that are resubmitted

Neil Horman (1):
      bonding: reset queue mapping prior to transmission to physical de=
vice (v5)

Nick Kossifidis (1):
      ath5k: Disable fast channel switching by default

Pablo Neira Ayuso (1):
      netfilter: nf_conntrack: fix ct refcount leak in l4proto->error()

Rafa=A9=A9 Mi=A9=A9ecki (1):
      ssb: fix PCI(e) driver regression causing oops on PCI cards

Russell King - ARM Linux (3):
      NET: am79c961: ensure asm() statements are marked volatile
      NET: am79c961: ensure multicast filter is correctly set at open
      NET: am79c961: fix assembler warnings

Stanislaw Gruszka (5):
      iwlagn: fix channel switch locking
      iwlagn: use cts-to-self protection on 5000 adapters series
      rt2x00: fix rmmod crash
      iwl4965: set tx power after rxon_assoc
      iwlegacy: fix channel switch locking

Steffen Klassert (2):
      xfrm: Fix off by one in the replay advance functions
      ipv4: Fix packet size calculation for raw IPsec packets in __ip_a=
ppend_data

Sucheta Chakraborty (1):
      qlcnic: Avoid double free of skb in tx path

Thadeu Lima de Souza Cascardo (1):
      mac80211: call dev_alloc_name before copying name to sdata

WANG Cong (1):
      netpoll: prevent netpoll setup on slave devices

Wey-Yi Guy (1):
      iwlagn: send tx power command if defer cause by RXON not match

Williams, Mitch A (1):
      igb: fix i350 SR-IOV failture

Wu Jiajun-B06378 (1):
      gianfar:localized filer table

Yegor Yefremov (1):
      ethtool.h: fix typos

 MAINTAINERS                                    |    2 +-
 arch/arm/mach-ep93xx/core.c                    |    6 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c          |    1 +
 drivers/net/arm/am79c961a.c                    |  126 ++++++++++++----=
--------
 drivers/net/arm/ep93xx_eth.c                   |   82 ++++++++--------
 drivers/net/bonding/bond_main.c                |   11 ++
 drivers/net/dl2k.c                             |    2 +-
 drivers/net/gianfar.c                          |   29 +++---
 drivers/net/gianfar.h                          |    8 +-
 drivers/net/gianfar_ethtool.c                  |   64 ++++++------
 drivers/net/igb/igb_main.c                     |    3 +
 drivers/net/qlcnic/qlcnic_hw.c                 |    1 +
 drivers/net/qlcnic/qlcnic_main.c               |    1 +
 drivers/net/smc91x.c                           |    6 +-
 drivers/net/wireless/ath/ath5k/base.c          |   11 ++-
 drivers/net/wireless/ath/ath5k/reset.c         |    5 +-
 drivers/net/wireless/iwlegacy/iwl-4965.c       |   12 +--
 drivers/net/wireless/iwlegacy/iwl-core.c       |   30 +++---
 drivers/net/wireless/iwlegacy/iwl-core.h       |    2 +-
 drivers/net/wireless/iwlegacy/iwl-dev.h        |   13 +---
 drivers/net/wireless/iwlegacy/iwl4965-base.c   |   20 ++--
 drivers/net/wireless/iwlwifi/iwl-2000.c        |   74 --------------
 drivers/net/wireless/iwlwifi/iwl-5000.c        |    3 -
 drivers/net/wireless/iwlwifi/iwl-6000.c        |    2 -
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c    |   12 +--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c    |   19 +++-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |   19 ++--
 drivers/net/wireless/iwlwifi/iwl-core.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.h        |    1 +
 drivers/net/wireless/iwlwifi/iwl-dev.h         |   13 +---
 drivers/net/wireless/iwlwifi/iwl-rx.c          |   24 +++---
 drivers/net/wireless/libertas/if_sdio.c        |   21 +++-
 drivers/net/wireless/rt2x00/rt2x00config.c     |    3 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c        |    4 +
 drivers/net/wireless/rtlwifi/pci.c             |   30 +++---
 drivers/ssb/driver_pcicore.c                   |   10 +-
 include/linux/ethtool.h                        |    6 +-
 include/linux/if_packet.h                      |    2 +
 include/linux/if_vlan.h                        |   25 ++++-
 include/linux/netdevice.h                      |    2 +-
 include/linux/netfilter/nf_conntrack_common.h  |    3 +
 include/linux/skbuff.h                         |    5 +
 net/8021q/vlan_core.c                          |   60 ++++++-----
 net/bridge/br_netfilter.c                      |    6 +
 net/core/dev.c                                 |   23 ++---
 net/core/net_namespace.c                       |   16 ++--
 net/core/netpoll.c                             |    7 ++
 net/ipv4/ip_output.c                           |    6 +-
 net/ipv4/netfilter/ip_queue.c                  |    3 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    6 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c            |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
 net/ipv4/netfilter/nf_nat_core.c               |    2 +-
 net/ipv4/netfilter/nf_nat_helper.c             |    2 +-
 net/ipv4/netfilter/nf_nat_rule.c               |    2 +-
 net/ipv4/netfilter/nf_nat_standalone.c         |    4 +-
 net/ipv4/route.c                               |   78 ++++++++-------
 net/ipv6/af_inet6.c                            |    4 +
 net/ipv6/netfilter/ip6_queue.c                 |    3 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/irda/iriap.c                               |    5 +
 net/l2tp/l2tp_debugfs.c                        |    2 +-
 net/mac80211/ibss.c                            |    6 +-
 net/mac80211/ieee80211_i.h                     |    3 -
 net/mac80211/iface.c                           |    4 +
 net/mac80211/key.c                             |   21 +----
 net/mac80211/mlme.c                            |    6 -
 net/mac80211/tx.c                              |    7 +-
 net/netfilter/ipset/ip_set_core.c              |    2 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   10 +-
 net/netfilter/ipset/ip_set_hash_net.c          |    8 +-
 net/netfilter/ipset/ip_set_hash_netport.c      |    6 +-
 net/netfilter/ipvs/ip_vs_core.c                |   16 ++--
 net/netfilter/nf_conntrack_core.c              |    7 +-
 net/netfilter/nf_conntrack_ftp.c               |    2 +-
 net/netfilter/nf_conntrack_h323_main.c         |   10 +-
 net/netfilter/nf_conntrack_irc.c               |    3 +-
 net/netfilter/nf_conntrack_pptp.c              |    3 +-
 net/netfilter/nf_conntrack_sane.c              |    2 +-
 net/netfilter/nf_conntrack_sip.c               |    2 +-
 net/netfilter/xt_socket.c                      |    4 +-
 net/packet/af_packet.c                         |    2 +
 net/sched/sch_generic.c                        |    3 +-
 net/wireless/nl80211.c                         |    9 +-
 net/xfrm/xfrm_replay.c                         |    4 +-
 87 files changed, 553 insertions(+), 545 deletions(-)
