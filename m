From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 20 Mar 2011 19:51:56 -0700 (PDT)
Message-ID: <20110320.195156.226769634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The R8169 PHY fix from Eric Dumazet, which I see you've added to
   your tree too. :-)

2) NIU driver broken by OF layer changes, fix by eliminating platform
   device name conflict.

3) Fix VHOST receive queue locking, from Michael S. Tsirkin.

4) Some gianfar chips are buggy wrt. checksums for certain packet
   buffer alignments, fall back to sw checksumming in those cases.
   From Alex Dubov.

5) ECONET leaks 4 uninitialized bytes to the network, fix from Vasiliy
   Kulikov.

6) Fix blind deref of ethtool_ops->set_sg(), fix from Roger Luethi.

7) ethtool_rxnfc needs syscall compat handling, from Ben Hutchings.

8) VLAN broken over gre tunnels because it does not take
   ->needed_headroom into account.  Fix from Eric Dumazet.

9) Bridging netfilter needs to init IPCB() of skb before injecting
   packet into the IP stack, fix from Herbert Xu.

10) ftmac100 has off-by-one error, fix by using resource_size().  Fix
    from Dan Carpenter.

11) IPSET fixes from Jozsef Kadlecsik.

12) Netfilter xtables has some reentrancy issues, fix from Eric Dumazet=
=2E

13) CLUSTERIP netfilter iptablesm module needs to check user buffer siz=
e
    more carefully, fix from Vasiliy Kulikov.

Please pull, thanks a lot!

The following changes since commit a44f99c7efdb88fa41128065c9a9445c1989=
4e34:

  Merge branch 'trivial' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/mmarek/kbuild-2.6 (2011-03-20 18:14:55 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alex Dubov (1):
      gianfar: Fall back to software tcp/udp checksum on older controll=
ers

Ben Hutchings (1):
      ethtool: Compat handling for struct ethtool_rxnfc

Dan Carpenter (1):
      ftmac100: use resource_size()

David S. Miller (3):
      niu: Rename NIU parent platform device name to fix conflict.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'vhost-net-next' of git://git.kernel.org/.../mst/vho=
st

Eric Dumazet (3):
      vlan: should take into account needed_headroom
      r8169: fix a bug in rtl8169_init_phy()
      netfilter: xtables: fix reentrancy

Herbert Xu (1):
      bridge: Reset IPCB when entering IP stack on NF_FORWARD

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

Nicolas de Peslo=FCan (1):
      bonding: fix a typo in a comment

Roger Luethi (1):
      ethtool: __ethtool_set_sg: check for function pointer before usin=
g it

Vasiliy Kulikov (2):
      econet: 4 byte infoleak to the network
      netfilter: ipt_CLUSTERIP: fix buffer overflow

 drivers/net/bonding/bond_main.c                |    2 +-
 drivers/net/ftmac100.c                         |    2 +-
 drivers/net/gianfar.c                          |   16 ++-
 drivers/net/gianfar.h                          |    1 +
 drivers/net/niu.c                              |    2 +-
 drivers/net/r8169.c                            |    4 +-
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
 net/8021q/vlan_dev.c                           |    1 +
 net/bridge/br_netfilter.c                      |    3 +
 net/core/ethtool.c                             |    3 +
 net/econet/af_econet.c                         |    2 +-
 net/ipv4/netfilter/ip_tables.c                 |    4 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    5 +-
 net/ipv6/netfilter/ip6_tables.c                |    4 +-
 net/netfilter/ipset/ip_set_core.c              |   22 +++-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   34 ++----
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   34 ++----
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   34 ++----
 net/netfilter/ipset/ip_set_hash_netport.c      |   30 ++----
 net/socket.c                                   |  114 ++++++++++++++++=
-
 28 files changed, 321 insertions(+), 284 deletions(-)
