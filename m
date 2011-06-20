From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 20 Jun 2011 14:20:00 -0700 (PDT)
Message-ID: <20110620.142000.1153242594731096037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) IPVS namespace exit causes crash in conntrack, fix from
   Hans Schillstrom.

2) ieee802154_nl_fill_phy() memory leak fix from Jesper Juhl.

3) Fix IRQ autoprobing regression in 3c503 driver, from
   Ondrej Zary.

4) Fix oops in mwifiex driver when probing setting using
   ethtool, from Yogesh Ashok Powar.

5) Netfilter NAT code adjusts sequence numbers one too many times
   over loopback, fix from Julian Anastasov.

6) Bridge multicast code sets ->mrouters_only on wrong SKB, fix
   from Fernando Luis Vazquez Cao.

7) Rik van Riel reports a regression of using netpoll over bridge
   slave devices.  What's happening now is that once we have a device
   become a slave, we cannot allow it to have netpoll run over it.

   The situations that care about this (virtualization) should run
   the netconsole instance over the bridge device, but that only
   works if all slave devices support polling.  The exception
   that makes this difficult is the TUN driver.

   Fortunately, adding netpoll support to TUN is entirely trivial
   because all of it's receive events are synchronously triggered.

   Fix from Neil Horman, tested by Rik van Riel.

8) VLAN code invokes OPS without checking if the underlying device
   supports the offload feature, fix from Antoine Reversat.

9) Memory leak fix in bfin_mac driver, from Sonic Zhang.

10) RFS steering doesn't happen on the first pack of a passive TCP
    flow due to a missing sock_rps_record_flow() call in both ipv4
    and ipv6.  Fix from Eric Dumazet.

11) Module ref leak fixes in farsync and gigaset drivers, from
    Pavel Shved.

12) inet_diag byte code audit code is buggy and can cause loops as
    well as unaligned accesses.  Fix from Eric Dumazet.

13) Fix regression in multicast route lookups cause by the conversion
    to return error pointers, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit ef46222e7b56e728e423527d430cb2013c59=
5491:

  Merge branch 'stable/bug.fixes' of git://git.kernel.org/pub/scm/linux=
/kernel/git/konrad/xen (2011-06-20 09:01:33 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Antoine Reversat (1):
      vlan: don't call ndo_vlan_rx_register on hardware that doesn't ha=
ve vlan support

Changli Gao (1):
      ppp: use PPP_TRANS instead of the magic number 0x20

Clive Stubbings (1):
      fs_enet: fix freescale FCC ethernet dp buffer alignment

David Miller (1):
      Bluetooth: Do not ignore errors returned from strict_strtol()

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'davem.r8169' of git://git.kernel.org/.../romieu/net=
dev-2.6

Eric Dumazet (6):
      net: rfs: enable RFS before first data packet is received
      inet_diag: fix inet_diag_bc_audit()
      ipv4: fix multicast losses
      hp100: fix an skb->len race
      sgi-xp: fix a use after free
      netxen: fix race in skb->len access

=46ernando Luis V=E1zquez Cao (2):
      IGMP snooping: set mrouters_only flag for IPv4 traffic properly
      IGMP snooping: set mrouters_only flag for IPv6 traffic properly

=46ilip Palian (1):
      Bluetooth: l2cap and rfcomm: fix 1 byte infoleak to userspace.

=46rancois Romieu (1):
      r8169: fix static initializers.

Geert Uytterhoeven (1):
      net/hplance: hplance_init() should be __devinit

Hans Schillstrom (1):
      IPVS netns exit causes crash in conntrack

Jesper Juhl (2):
      ieee802154: Don't leak memory in ieee802154_nl_fill_phy
      ipv4, ping: Remove duplicate icmp.h include

Joe Perches (1):
      MAINTAINERS: Update EBTABLES mailing list

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into for-davem

Julian Anastasov (1):
      netfilter: nf_nat: avoid double seq_adjust for loopback

Luiz Augusto von Dentz (1):
      Bluetooth: fix shutdown on SCO sockets

Marius B. Kotsbak (1):
      net/usb: Add Samsung Kalmia driver for Samsung GT-B3730

Neil Horman (1):
      tun: teach the tun/tap driver to support netpoll

Nicolas Cavallari (1):
      netfilter: fix looped (broad|multi)cast's MAC handling

Nishant Sarmukadam (1):
      mwl8k: Tell firmware to generate CCMP header

Ondrej Zary (1):
      3c503: fix broken IRQ autoprobing

Patrick McHardy (3):
      Merge branch 'master' of git://git.kernel.org/.../horms/ipvs-2.6
      netfilter: ipt_ecn: fix protocol check in ecn_mt_check()
      netfilter: ipt_ecn: fix inversion for IP header ECN match

Pavel Shved (2):
      farsync: add module_put to error path in fst_open()
      gigaset: call module_put before restart of if_open()

Ralf Baechle (1):
      phylib: Allow BCM63XX PHY to be selected only on BCM63XX.

Richard Cochran (3):
      dp83640: fix phy status frame event parsing
      dp83640: drop PHY status frames in the driver.
      pxa168_eth: fix race in transmit path.

Sebastian Andrzej Siewior (1):
      netfilter: ip_tables: fix compile with debug

Sonic Zhang (1):
      netdev: bfin_mac: fix memory leak when freeing dma descriptors

Ville Tervo (1):
      Bluetooth: Do not send SET_EVENT_MASK for 1.1 and earlier devices

WANG Cong (1):
      netpoll: copy dev name of slaves to struct netpoll

Yogesh Ashok Powar (1):
      mwifiex: Fixing NULL pointer dereference

sjur.brandeland@stericsson.com (1):
      caif: Bugfix - XOFF removed channel from caif-mux

 MAINTAINERS                                    |    3 +-
 drivers/bluetooth/btmrvl_debugfs.c             |   12 +
 drivers/isdn/gigaset/interface.c               |    4 +-
 drivers/misc/sgi-xp/xpnet.c                    |    6 +-
 drivers/net/3c503.c                            |    3 +-
 drivers/net/bfin_mac.c                         |   20 +-
 drivers/net/bonding/bond_main.c                |    1 +
 drivers/net/fs_enet/mac-fcc.c                  |    2 +-
 drivers/net/hp100.c                            |    4 +-
 drivers/net/hplance.c                          |    2 +-
 drivers/net/netxen/netxen_nic_main.c           |    4 +-
 drivers/net/phy/Kconfig                        |    1 +
 drivers/net/phy/dp83640.c                      |   24 +-
 drivers/net/ppp_async.c                        |    4 +-
 drivers/net/pxa168_eth.c                       |    2 +-
 drivers/net/r8169.c                            |   10 +-
 drivers/net/tun.c                              |   24 ++-
 drivers/net/usb/Kconfig                        |   10 +
 drivers/net/usb/Makefile                       |    1 +
 drivers/net/usb/kalmia.c                       |  384 ++++++++++++++++=
++++++++
 drivers/net/wan/farsync.c                      |    4 +-
 drivers/net/wireless/mwifiex/cfg80211.c        |    2 +
 drivers/net/wireless/mwl8k.c                   |    4 +-
 include/net/netfilter/nf_conntrack.h           |    6 +
 net/8021q/vlan.c                               |    2 +-
 net/bluetooth/hci_event.c                      |   18 +-
 net/bluetooth/l2cap_sock.c                     |    1 +
 net/bluetooth/rfcomm/sock.c                    |    1 +
 net/bluetooth/sco.c                            |   13 +-
 net/bridge/br_device.c                         |    1 +
 net/bridge/br_multicast.c                      |    4 +-
 net/caif/cfmuxl.c                              |    2 +-
 net/ieee802154/nl-phy.c                        |    3 +-
 net/ipv4/af_inet.c                             |    1 +
 net/ipv4/inet_diag.c                           |   14 +-
 net/ipv4/netfilter/ip_queue.c                  |    3 +-
 net/ipv4/netfilter/ip_tables.c                 |    2 +-
 net/ipv4/netfilter/ipt_ecn.c                   |    7 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 +-
 net/ipv4/ping.c                                |    1 -
 net/ipv4/route.c                               |    4 +-
 net/ipv4/tcp_ipv4.c                            |    1 +
 net/ipv6/netfilter/ip6_queue.c                 |    3 +-
 net/ipv6/tcp_ipv6.c                            |    1 +
 net/netfilter/ipvs/ip_vs_conn.c                |   10 +-
 net/netfilter/ipvs/ip_vs_core.c                |    1 +
 net/netfilter/nfnetlink_log.c                  |    3 +-
 net/netfilter/nfnetlink_queue.c                |    3 +-
 48 files changed, 563 insertions(+), 77 deletions(-)
 create mode 100644 drivers/net/usb/kalmia.c
