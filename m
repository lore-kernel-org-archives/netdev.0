From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 17 Sep 2009 10:54:51 -0700 (PDT)
Message-ID: <20090917.105451.66819270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758857AbZIQRyg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The idea to use ->close() and then a ->open() to refresh multicast
   addresses in the bonding driver was a bad idea and breaks a bunch
   of stuff.  Better scheme from Moni Shoua.

2) Some TCP code still assuming ssthresh was a u16, oops.  Fix from
   Ilpo J=E4rvinen.

3) RXRPC updates from David Howells.

4) genetlink table locking busted with netns, fix from Johannes Berg.

5) Several fixes for multiq packet scheduler fallout from Jarek Poplaws=
ki.

6) can receives packets in wrong context eliciting warnings from
   local_softirq_pending(), fix from Oliver Hartkopp.

7) TCP MD5 code has preempt level imbalance, fix from Robert Varga.

8) SKY2 bug fixes from Stephen Hemminger.

9) Alexey Dobriyan is const'ified several protocol and ops structures.

10) Wireless bug fixes via John Linville.

11) IPV6 conformance fix wrt ROUTER_PREF_INVALID options and making
    the DAD failure log message more informative, from Jens Rosenboom.

12) S390 IUCV stack fixes from Ursula Braun and Hendrik Brueckner.

13) ieee802154 stack fixes from Dmitry Eremin-Solenikov.

Please pull, thanks a lot!

The following changes since commit 4142e0d1def2c0176c27fd2e810243045a62=
eb6d:
  Linus Torvalds (1):
        Merge branch 'osync_cleanup' of git://git.kernel.org/.../jack/l=
inux-fs-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (2):
      igb: reset sgmii phy at start of init
      igb: do not allow phy sw reset code to make calls to null pointer=
s

Alexey Dobriyan (3):
      net: constify struct net_protocol
      net: constify struct inet6_protocol
      net: constify remaining proto_ops

Christian Lamparter (1):
      p54usb: add Zcomax XG-705A usbid

Daniel C Halperin (1):
      iwlwifi: fix HT operation in 2.4 GHz band

David Howells (5):
      RxRPC: Declare the security index constants symbolically
      RxRPC: Allow key payloads to be passed in XDR form
      RxRPC: Allow RxRPC keys to be read
      RxRPC: Parse security index 5 keys (Kerberos 5)
      RxRPC: Use uX/sX rather than uintX_t/intX_t types

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'for-linus' of git://git.kernel.org/.../lowpan/lowpa=
n
      wl12xx: Fix print_mac() conversion.

Dmitry Eremin-Solenikov (2):
      af_ieee802154: setsockopt optlen arg isn't __user
      ieee802154: add locking for seq numbers

Dongdong Deng (1):
      b44: the poll handler b44_poll must not enable IRQ unconditionall=
y

Eric Dumazet (1):
      net: kmemcheck annotation in struct socket

Gerrit Renker (1):
      net-next-2.6 [PATCH 1/1] dccp: ccids whitespace-cleanup / CodingS=
tyle

Hendrik Brueckner (6):
      iucv: fix iucv_buffer_cpumask check when calling IUCV functions
      iucv: use correct output register in iucv_query_maxconn()
      af_iucv: fix race in __iucv_sock_wait()
      af_iucv: handle non-accepted sockets after resuming from suspend
      af_iucv: do not call iucv_sock_kill() twice
      af_iucv: fix race when queueing skbs on the backlog queue

Holger Schurig (2):
      cfg80211: use cfg80211_wext_freq() for freq conversion
      cfg80211: minimal error handling for wext-compat freq scanning

Ilpo J=E4rvinen (1):
      tcp: fix ssthresh u16 leftover

Jarek Poplawski (4):
      pkt_sched: Fix qdisc_graft WRT ingress qdisc
      pkt_sched: Fix tx queue selection in tc_modify_qdisc
      pkt_sched: Fix qdisc_create on stab error handling
      pkt_sched: Fix qstats.qlen updating in dump_stats

Jean-Christophe PLAGNIOL-VILLARD (1):
      wl12xx: switch to %pM to print the mac address

Jens Rosenboom (2):
      ipv6: Ignore route option with ROUTER_PREF_INVALID
      ipv6: Log the affected address when DAD failure occurs

Jie Yang (1):
      atl1e: fix 2.6.31-git4 -- ATL1E 0000:03:00.0: DMA-API: device dri=
ver frees DMA

Jiri Pirko (1):
      bonding: make ab_arp select active slaves as other modes

Johannes Berg (3):
      iwlwifi: disable powersave for 4965
      genetlink: fix netns vs. netlink table locking
      cfg80211: fix SME connect

Ken Kawasaki (1):
      pcnet_cs: add cis of Linksys multifunction pcmcia card

Larry Finger (1):
      ssb: Fix error when V1 SPROM extraction is forced

Luis R. Rodriguez (1):
      wireless: default CONFIG_WLAN to y

Mark Smith (1):
      Have atalk_route_packet() return NET_RX_SUCCESS not NET_XMIT_SUCC=
ESS

Martin Decky (1):
      hostap: Revert a toxic part of the conversion to net_device_ops

Michael Buesch (3):
      b43: Force-wake queues on init
      ssb: Disable verbose SDIO coreswitch
      b43: Fix resume failure

Michael Hennerich (1):
      netdev: smc91x: drop Blackfin cruft

Moni Shoua (1):
      bonding: remap muticast addresses without using dev_close() and d=
ev_open()

Oliver Hartkopp (1):
      can: fix NOHZ local_softirq_pending 08 warning

Pavel Roskin (1):
      rc80211_minstrel: fix contention window calculation

Peter P Waskiewicz Jr (3):
      ixgbe: Properly disable packet split per-ring when globally disab=
led
      ixgbe: Add support for 82599-based CX4 adapters
      ixgbe: Create separate media type for CX4 adapters

Randy Dunlap (1):
      ssb/sdio: fix printk format warnings

Reinette Chatre (1):
      iwlwifi: fix potential rx buffer loss

Robert Varga (1):
      tcp: fix CONFIG_TCP_MD5SIG + CONFIG_PREEMPT timer BUG()

R=E9mi Denis-Courmont (2):
      Phonet: Netlink event for autoconfigured addresses
      cdc-phonet: remove noisy debug statement

Sathya Perla (1):
      be2net: fix some cmds to use mccq instead of mbox

Stephen Hemminger (2):
      sky2: transmit ring accounting
      sky2: Make sure both ports initialize correctly

Sujith (1):
      ath9k: Fix bug in ANI channel handling

Ursula Braun (1):
      iucv: suspend/resume error msg for left over pathes

Vitaliy Gusev (1):
      mlx4: Fix access to freed memory

Wey-Yi Guy (1):
      iwlwifi: find the correct first antenna

 drivers/net/atl1e/atl1e.h                   |    9 +
 drivers/net/atl1e/atl1e_main.c              |   15 +-
 drivers/net/b44.c                           |    7 +-
 drivers/net/benet/be.h                      |    1 +
 drivers/net/benet/be_cmds.c                 |  412 +++++++-----
 drivers/net/benet/be_cmds.h                 |    5 +-
 drivers/net/benet/be_main.c                 |   42 +-
 drivers/net/bonding/bond_main.c             |  131 ++---
 drivers/net/can/vcan.c                      |    2 +-
 drivers/net/igb/e1000_82575.c               |  198 +++---
 drivers/net/igb/e1000_82575.h               |    2 +-
 drivers/net/igb/e1000_defines.h             |    2 +-
 drivers/net/igb/e1000_phy.c                 |    5 +-
 drivers/net/igb/igb_main.c                  |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c             |    6 +-
 drivers/net/ixgbe/ixgbe_82599.c             |    3 +
 drivers/net/ixgbe/ixgbe_main.c              |    4 +
 drivers/net/ixgbe/ixgbe_type.h              |    2 +
 drivers/net/mlx4/catas.c                    |   11 +-
 drivers/net/pcmcia/pcnet_cs.c               |   10 +-
 drivers/net/pppol2tp.c                      |    4 +-
 drivers/net/sky2.c                          |   24 +-
 drivers/net/smc91x.h                        |   28 -
 drivers/net/usb/cdc-phonet.c                |    1 -
 drivers/net/wireless/Kconfig                |    1 +
 drivers/net/wireless/ath/ath9k/ani.c        |    6 +-
 drivers/net/wireless/b43/main.c             |    8 +-
 drivers/net/wireless/hostap/hostap_main.c   |    3 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   10 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |    9 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c    |    5 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   24 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   24 +-
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/wl12xx/wl1271_main.c   |    5 +-
 drivers/serial/serial_cs.c                  |   14 +-
 drivers/ssb/pci.c                           |    1 +
 drivers/ssb/sdio.c                          |    6 +-
 firmware/Makefile                           |    3 +-
 firmware/WHENCE                             |   12 +
 firmware/cis/MT5634ZLX.cis.ihex             |   11 +
 firmware/cis/PCMLM28.cis.ihex               |   18 +
 firmware/cis/RS-COM-2P.cis.ihex             |   10 +
 include/keys/rxrpc-type.h                   |  107 ++++
 include/linux/igmp.h                        |    2 +
 include/linux/net.h                         |    5 +
 include/linux/netdevice.h                   |    3 +-
 include/linux/netlink.h                     |    4 +
 include/linux/notifier.h                    |    2 +
 include/linux/rxrpc.h                       |    7 +
 include/net/addrconf.h                      |    2 +
 include/net/protocol.h                      |   13 +-
 include/net/sch_generic.h                   |    2 +-
 include/net/tcp.h                           |    7 +
 net/appletalk/ddp.c                         |    2 +-
 net/can/af_can.c                            |    4 +-
 net/core/dev.c                              |    4 +-
 net/dccp/ccids/Kconfig                      |    6 +-
 net/dccp/ccids/ccid2.c                      |    2 -
 net/dccp/ccids/ccid2.h                      |    8 +-
 net/dccp/ccids/ccid3.c                      |    5 +-
 net/dccp/ccids/ccid3.h                      |   50 +-
 net/dccp/ccids/lib/loss_interval.c          |    7 +-
 net/dccp/ccids/lib/loss_interval.h          |    2 -
 net/dccp/ccids/lib/packet_history.c         |    4 +-
 net/dccp/ccids/lib/packet_history.h         |    1 -
 net/dccp/ccids/lib/tfrc.h                   |    4 +-
 net/dccp/ccids/lib/tfrc_equation.c          |   26 +-
 net/dccp/ipv4.c                             |    2 +-
 net/dccp/ipv6.c                             |    4 +-
 net/ieee802154/dgram.c                      |    2 +-
 net/ieee802154/netlink.c                    |    4 +
 net/ieee802154/raw.c                        |    2 +-
 net/ipv4/af_inet.c                          |   18 +-
 net/ipv4/ah4.c                              |    2 +-
 net/ipv4/devinet.c                          |    6 +
 net/ipv4/esp4.c                             |    2 +-
 net/ipv4/icmp.c                             |    2 +-
 net/ipv4/igmp.c                             |   22 +
 net/ipv4/ip_gre.c                           |    2 +-
 net/ipv4/ip_input.c                         |    2 +-
 net/ipv4/ipcomp.c                           |    2 +-
 net/ipv4/ipmr.c                             |    6 +-
 net/ipv4/protocol.c                         |    6 +-
 net/ipv4/tcp.c                              |    2 +-
 net/ipv4/tcp_input.c                        |    2 +-
 net/ipv4/tcp_ipv4.c                         |    4 +-
 net/ipv4/tcp_minisocks.c                    |    4 +-
 net/ipv4/tunnel4.c                          |    4 +-
 net/ipv4/udplite.c                          |    2 +-
 net/ipv6/addrconf.c                         |   23 +-
 net/ipv6/af_inet6.c                         |   10 +-
 net/ipv6/ah6.c                              |    2 +-
 net/ipv6/esp6.c                             |    2 +-
 net/ipv6/exthdrs.c                          |    6 +-
 net/ipv6/icmp.c                             |    4 +-
 net/ipv6/ip6_input.c                        |    2 +-
 net/ipv6/ip6mr.c                            |    6 +-
 net/ipv6/ipcomp6.c                          |    2 +-
 net/ipv6/mcast.c                            |   19 +
 net/ipv6/protocol.c                         |    6 +-
 net/ipv6/reassembly.c                       |    2 +-
 net/ipv6/route.c                            |    2 +-
 net/ipv6/tcp_ipv6.c                         |    7 +-
 net/ipv6/tunnel6.c                          |    4 +-
 net/ipv6/udp.c                              |    2 +-
 net/ipv6/udplite.c                          |    2 +-
 net/iucv/af_iucv.c                          |   33 +-
 net/iucv/iucv.c                             |   38 +-
 net/mac80211/rc80211_minstrel.c             |    2 +-
 net/netlink/af_netlink.c                    |   51 +-
 net/netlink/genetlink.c                     |    5 +-
 net/phonet/pn_dev.c                         |    9 +-
 net/rds/af_rds.c                            |    2 +-
 net/rose/af_rose.c                          |    4 +-
 net/rxrpc/ar-ack.c                          |    6 +-
 net/rxrpc/ar-internal.h                     |   32 +-
 net/rxrpc/ar-key.c                          |  914 +++++++++++++++++++=
++++++--
 net/rxrpc/ar-security.c                     |    8 +-
 net/rxrpc/rxkad.c                           |   47 +-
 net/sched/sch_api.c                         |   29 +-
 net/sched/sch_drr.c                         |    4 +-
 net/sched/sch_mq.c                          |   14 +-
 net/sched/sch_multiq.c                      |    1 +
 net/sched/sch_prio.c                        |    1 +
 net/sctp/ipv6.c                             |    2 +-
 net/sctp/protocol.c                         |    2 +-
 net/socket.c                                |    1 +
 net/wireless/scan.c                         |    7 +-
 net/wireless/sme.c                          |   21 +-
 132 files changed, 2009 insertions(+), 805 deletions(-)
 create mode 100644 firmware/cis/MT5634ZLX.cis.ihex
 create mode 100644 firmware/cis/PCMLM28.cis.ihex
 create mode 100644 firmware/cis/RS-COM-2P.cis.ihex
