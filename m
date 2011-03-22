From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Mon, 21 Mar 2011 21:09:36 -0700 (PDT)
Message-ID: <20110321.210936.191406640.davem@davemloft.net>
References: <20110320.195156.226769634.davem@davemloft.net>
	<AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 21 Mar 2011 12:24:12 -0700

> That said, I'm delaying this pull request due to the known issues wit=
h
> it - let me know when you've updated it with the fix for the
> use-after-free fixes and the slab corruptor (the latter of which I
> haven't seen a patch for yet)

I've intergrated several bug fixes, including those for all of the
problems Ingo reported:

1) Non-netlink ipsec configurations fail to initialize
   replay info, resulting in OOPS.  Fix from Wei Yongjun.

2) L2TP marks l2tp_eth_net_ops as __net_initdata causing OOPS
   on module unload, fix from James Chapman.

3) lock_kernel removal regression fixes from Eric Dumazet and
   Arnd Bergmann.  Both IPX and Appletalk could release a socket
   while holding that socket's lock.

4) C_CAN driver enables interrupts before chip is actually ready,
   fix from Jan Altenberg.

5) Use after free in macvlan, fix from Eric W. Biederman.

6) ipv6 creates dup "neigh" sysfs directories, also from Eric
   W. Biederman.

7) VETH over-increments TX/RX byte counters, also from Eric
   W. Biederman.

8) Two IPVS bug fixes:
   a) Reverse NULL check after allocation, from Eric Dumazet.
   b) mutex lockdep key invalidly in dynamic memory, fix from
      Simon Horman.

Please pull, thanks a lot:

The following changes since commit a44f99c7efdb88fa41128065c9a9445c1989=
4e34:

  Merge branch 'trivial' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/mmarek/kbuild-2.6 (2011-03-20 18:14:55 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alex Dubov (1):
      gianfar: Fall back to software tcp/udp checksum on older controll=
ers

Arnd Bergmann (1):
      net/appletalk: fix atalk_release use after free

Ben Hutchings (1):
      ethtool: Compat handling for struct ethtool_rxnfc

Dan Carpenter (1):
      ftmac100: use resource_size()

David S. Miller (3):
      niu: Rename NIU parent platform device name to fix conflict.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'vhost-net-next' of git://git.kernel.org/.../mst/vho=
st

Eric Dumazet (6):
      vlan: should take into account needed_headroom
      r8169: fix a bug in rtl8169_init_phy()
      netfilter: xtables: fix reentrancy
      snmp: SNMP_UPD_PO_STATS_BH() always called from softirq
      ipx: fix ipx_release()
      ipvs: fix a typo in __ip_vs_control_init()

Eric W. Biederman (3):
      macvlan: Fix use after free of struct macvlan_port.
      net ipv6: Fix duplicate /proc/sys/net/ipv6/neigh directory entrie=
s.
      veth: Fix the byte counters

Herbert Xu (1):
      bridge: Reset IPCB when entering IP stack on NF_FORWARD

James Chapman (1):
      l2tp: fix possible oops on l2tp_eth module unload

Jan Altenberg (1):
      can: c_can: Do basic c_can configuration _before_ enabling the in=
terrupts

Jason Wang (3):
      vhost-net: check the support of mergeable buffer outside the rece=
ive loop
      vhost-net: Unify the code of mergeable and big buffer handling
      vhost: lock receive queue, not the socket

Jozsef Kadlecsik (2):
      netfilter: ipset: fix address ranges at hash:*port* types
      netfilter: ipset: fix checking the type revision at create comman=
d

Krishna Kumar (1):
      vhost: Cleanup vhost.c and net.c

Michael S. Tsirkin (2):
      vhost: copy_from_user -> __copy_from_user
      vhost-net: remove unlocked use of receive_queue

Mike Frysinger (1):
      headers: use __aligned_xx types for userspace

Neil Horman (1):
      net: fix incorrect spelling in drop monitor protocol

Nicolas de Peslo=FCan (1):
      bonding: fix a typo in a comment

Roger Luethi (1):
      ethtool: __ethtool_set_sg: check for function pointer before usin=
g it

Simon Horman (1):
      IPVS: Use global mutex in ip_vs_app.c

Vasiliy Kulikov (2):
      econet: 4 byte infoleak to the network
      netfilter: ipt_CLUSTERIP: fix buffer overflow

Wei Yongjun (1):
      xfrm: Fix initialize repl field of struct xfrm_state

 drivers/net/bonding/bond_main.c                |    2 +-
 drivers/net/can/c_can/c_can.c                  |    6 +-
 drivers/net/ftmac100.c                         |    2 +-
 drivers/net/gianfar.c                          |   16 ++-
 drivers/net/gianfar.h                          |    1 +
 drivers/net/macvlan.c                          |   18 ++-
 drivers/net/niu.c                              |    2 +-
 drivers/net/r8169.c                            |    4 +-
 drivers/net/veth.c                             |    2 +-
 drivers/vhost/net.c                            |  159 ++++------------=
--------
 drivers/vhost/vhost.c                          |   55 ++++++---
 include/linux/ethtool.h                        |   34 +++++
 include/linux/if_ppp.h                         |   16 ++--
 include/linux/netfilter/ipset/ip_set_getport.h |   10 ++
 include/linux/netfilter/nfnetlink_log.h        |    4 +-
 include/linux/netfilter/nfnetlink_queue.h      |    4 +-
 include/linux/netfilter/xt_connbytes.h         |    4 +-
 include/linux/netfilter/xt_quota.h             |    2 +-
 include/net/ip_vs.h                            |    2 -
 include/net/snmp.h                             |    4 +-
 include/net/xfrm.h                             |    1 +
 net/8021q/vlan_dev.c                           |    1 +
 net/appletalk/ddp.c                            |    3 +
 net/bridge/br_netfilter.c                      |    3 +
 net/core/drop_monitor.c                        |    2 +-
 net/core/ethtool.c                             |    3 +
 net/econet/af_econet.c                         |    2 +-
 net/ipv4/netfilter/ip_tables.c                 |    4 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    5 +-
 net/ipv6/netfilter/ip6_tables.c                |    4 +-
 net/ipv6/sysctl_net_ipv6.c                     |   18 ++-
 net/ipx/af_ipx.c                               |    2 +-
 net/l2tp/l2tp_eth.c                            |    2 +-
 net/netfilter/ipset/ip_set_core.c              |   22 +++-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   34 ++----
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   34 ++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   34 ++----
 net/netfilter/ipset/ip_set_hash_netport.c      |   30 ++----
 net/netfilter/ipvs/ip_vs_app.c                 |   23 ++--
 net/netfilter/ipvs/ip_vs_ctl.c                 |    2 +-
 net/socket.c                                   |  114 ++++++++++++++++=
-
 net/xfrm/xfrm_state.c                          |   15 ++-
 net/xfrm/xfrm_user.c                           |    2 +-
 43 files changed, 383 insertions(+), 324 deletions(-)
