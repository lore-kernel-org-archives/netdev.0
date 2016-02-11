From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 11 Feb 2016 03:39:53 -0500 (EST)
Message-ID: <20160211.033953.421229386600116297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix BPF handling of branch offset adjustmnets on backjumps, from Daniel
   Borkmann.

2) Make sure selinux knows about SOCK_DESTROY netlink messages, from
   Lorenzo Colitti.

3) Fix openvswitch tunnel mtu regression, from David Wragg.

4) Fix ICMP handling of TCP sockets in syn_recv state, from Eric
   Dumazet.

5) Fix SCTP user hmacid byte ordering bug, from Xin Long.

6) Fix recursive locking in ipv6 addrconf, from Subash Abhinov
   Kasiviswanathan.

Please pull, thanks a lot!

The following changes since commit 34229b277480f46c1e9a19f027f30b074512e68b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-02-01 15:56:08 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to a1b14d27ed0965838350f1377ff97c93ee383492:

  bpf: fix branch offset adjustment on backjumps after patching ctx expansion (2016-02-10 16:56:47 -0500)

----------------------------------------------------------------
Aaro Koskinen (1):
      of: of_mdio: Add marvell, 88e1145 to whitelist of PHY compatibilities.

Alexander Duyck (1):
      flow_dissector: Fix unaligned access in __skb_flow_dissector when used by eth_get_headlen

Daniel Borkmann (1):
      bpf: fix branch offset adjustment on backjumps after patching ctx expansion

David S. Miller (1):
      Merge branch 'ovs-tunnel-mtu'

David Wragg (3):
      vxlan: Relax MTU constraints
      geneve: Relax MTU constraints
      vxlan, gre, geneve: Set a large MTU on ovs-created tunnel devices

Eric Dumazet (2):
      ipv6: fix a lockdep splat
      tcp: do not drop syn_recv on all icmp reports

Hannes Frederic Sowa (1):
      unix: correctly track in-flight fds in sending process user_struct

Hans Westgaard Ry (1):
      net:Add sysctl_max_skb_frags

Lorenzo Colitti (1):
      selinux: nlmsgtab: add SOCK_DESTROY to the netlink mapping tables

Rabin Vincent (1):
      dwc_eth_qos: Reset hardware before PHY start

Sandeep Pillai (1):
      enic: increment devcmd2 result ring in case of timeout

Sathya Perla (1):
      update be2net maintainers' email addresses

Siva Reddy Kallam (1):
      tg3: Fix for tg3 transmit queue 0 timed out when too many gso_segs

Xin Long (1):
      sctp: translate network order to host order when users get a hmacid

subashab@codeaurora.org (1):
      ipv6: addrconf: Fix recursive spin lock call

 MAINTAINERS                                 |  9 +++++----
 drivers/net/ethernet/broadcom/tg3.c         | 25 +++++++++++++++++++------
 drivers/net/ethernet/cisco/enic/enic.h      |  2 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c  | 19 ++++++++++++-------
 drivers/net/ethernet/synopsys/dwc_eth_qos.c |  2 +-
 drivers/net/geneve.c                        | 31 ++++++++++++++++++++++++++-----
 drivers/net/vxlan.c                         | 47 +++++++++++++++++++++++++++++++++--------------
 drivers/of/of_mdio.c                        |  1 +
 include/linux/skbuff.h                      |  1 +
 include/net/af_unix.h                       |  4 ++--
 include/net/ip_tunnels.h                    |  1 +
 include/net/scm.h                           |  1 +
 include/net/tcp.h                           |  2 +-
 kernel/bpf/verifier.c                       |  2 +-
 net/core/flow_dissector.c                   |  9 ++++++---
 net/core/scm.c                              |  7 +++++++
 net/core/skbuff.c                           |  2 ++
 net/core/sysctl_net_core.c                  | 10 ++++++++++
 net/ipv4/ip_gre.c                           |  8 ++++++++
 net/ipv4/ip_tunnel.c                        | 20 +++++++++++++++++---
 net/ipv4/tcp.c                              |  4 ++--
 net/ipv4/tcp_ipv4.c                         | 11 ++++++++---
 net/ipv6/addrconf.c                         |  5 ++++-
 net/ipv6/ip6_flowlabel.c                    |  5 +++--
 net/ipv6/tcp_ipv6.c                         |  5 +++--
 net/openvswitch/vport-vxlan.c               |  2 ++
 net/sctp/socket.c                           |  9 +++++++--
 net/unix/af_unix.c                          |  4 ++--
 net/unix/garbage.c                          |  8 ++++----
 security/selinux/nlmsgtab.c                 |  1 +
 30 files changed, 191 insertions(+), 66 deletions(-)
