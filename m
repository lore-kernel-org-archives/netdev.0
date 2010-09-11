From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 10 Sep 2010 21:26:06 -0700 (PDT)
Message-ID: <20100910.212606.226784672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some fixes for regressions added this merge window in here, but some
fixes are for some even older regressions too :-/

1) Fine grained MII locking regression fix in 3c59x driver from
   Ben Hutchings.

2) Off by one in NULL termination in IRDA stack.  Fix from Dan
   Carpenter.

3) Exhausting bind naming space in AF_UNIX can make unix_autobind()
   loop forever.  Fix from Tetsuo Handa.

4) Multipath routing breaks reverse-patch filtering.  It would just
   assume a device match when multiple hops exist for a route, instead
   of properly walking the next-hops array to find a device match.

5) VIA velocity emits lots of DMA debug assertions, and attempts to fix
   those lead to functional regressions, so turn scatter-gather
   support back off by default until we can find a way to fix this
   properly.

   Thanks to Dave Jones for the report and patch testing.

6) Follow-up fix to Eric Dumazet's GRO packet merging adjustments to
   handle differing headroom amounts properly.  From Jarek Poplawski.
   Thanks to Plamen Patrov for the original crash report and seemingly
   endless help with testing.

7) Fix interactions between VHOST and control groups, from Michael S.
   Tsirkin.

8) be2net driver fixes from Ajit Khaparde, wrong stats bump on multicast,
   fix uncorrectable error detection, remove invalid BUG_ON() assertion.

9) stmmac sleeps while holding a spinlock, fix from Giuseppe Cavallaro,
   report by Jiri Slaby.

10) Jiffies overflows in bonding ARp load balancer, from Jiri Bohac.

11) When bridging, need to use device ->select_queue() override when
    present otherwise wireless devices fail, from Helmut Schaa.

12) In IPV6 overlapping fragments are now considered completely illegal,
    because they allow bypassing of firewall rules (ie. first frag has
    TCP header with flow information that's allowed, next flag overlaps
    and overwrites TCP header with attacker's desired ports).  From
    Nicolas Dichtel.

13) Get b44 fifo recovery down to 20msc from several seconds because it
    can happen frequently for users, from Mark Lord and James
    Courtier-Dutton.

14) Active FTP regression fix in IPVS from Julian Anastasov.

15) Potential buffer overflow in niu driver ethtool code, from
    Ben Hutchings.

16) FIB trie lockdep-RCU fixes from Jarek Poplawski.

17) Always relookup routes currently pointing to the blackhole rule,
    as these routes are temporary.  This fixes regressions in IPSEC.
    Fix from Jianzhao Wang.

18) Fix a UDP hashing regression added in 2.6.33, the secondary hash needs
    to be recalculated when the implicit local address change happens
    as a side effect of connect().  From Eric Dumazet.

19) KS8851 RX packet allocation can missize the buffer and allow
    memory corruption.  From Eric Dumazet and Abraham Arce.

20) SCTP address validation tests list_head iterater against NULL
    but that's not what such an iterator is set to when a
    list_for_each_entry() loop exits normally.  From Joe Perches
    and Dan Carpenter.

21) ipheth is marked as "wwan" net device type, but that is not correct.
    Fix from Dan Williams.

Please pull, thanks a lot!

The following changes since commit 3e6dce76d99b328716b43929b9195adfee1de00c:

  Merge branch 'drm-intel-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/ickle/drm-intel (2010-09-10 18:19:43 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (3):
      be2net: fix net-snmp error because of wrong packet stats
      be2net: fix a bug in UE detection logic
      be2net: remove a BUG_ON in be_cmds.c

Ben Hutchings (2):
      3c59x: Fix deadlock in vortex_error()
      niu: Fix kernel buffer overflow for ETHTOOL_GRXCLSRLALL

Dan Carpenter (1):
      irda: off by one

Dan Williams (1):
      ipheth: remove incorrect devtype to WWAN

David S. Miller (4):
      ipv4: Fix reverse path filtering with multipath routing.
      via-velocity: Turn scatter-gather support back off.
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost

Eric Dumazet (2):
      udp: add rehash on connect()
      KS8851: Correct RX packet allocation

Giuseppe Cavallaro (1):
      stmmac: fix sleep inside atomic

Helmut Schaa (1):
      net: fix tx queue selection for bridged devices implementing select_queue

Jarek Poplawski (2):
      gro: Re-fix different skb headrooms
      ipv4: Suppress lockdep-RCU false positive in FIB trie (3)

Jianzhao Wang (1):
      net: blackhole route should always be recalculated

Jiri Bohac (1):
      bonding: Fix jiffies overflow problems (again)

Joe Perches (2):
      sctp: fix test for end of loop
      MAINTAINERS: Add CAIF

Julian Anastasov (1):
      ipvs: fix active FTP

Li Zefan (1):
      cls_cgroup: Fix rcu lockdep warning

Mark Lord (1):
      PATCH: b44 Handle RX FIFO overflow better (simplified)

Michael S. Tsirkin (3):
      cgroups: fix API thinko
      vhost: fix attach to cgroups regression
      vhost: error handling fix

Nicolas Dichtel (2):
      ipv6: discard overlapping fragment
      netfilter: discard overlapping IPv6 fragment

Tetsuo Handa (1):
      UNIX: Do not loop forever at unix_autobind().

 MAINTAINERS                             |   10 ++++
 drivers/net/3c59x.c                     |   10 +++-
 drivers/net/b44.c                       |    9 ++++
 drivers/net/benet/be.h                  |    1 +
 drivers/net/benet/be_cmds.c             |    8 +--
 drivers/net/benet/be_cmds.h             |    2 +-
 drivers/net/benet/be_ethtool.c          |    1 +
 drivers/net/benet/be_hw.h               |    7 ++-
 drivers/net/benet/be_main.c             |   47 +++++++-----------
 drivers/net/bonding/bond_main.c         |   56 +++++++++++++++-------
 drivers/net/ks8851.c                    |   39 ++++++++-------
 drivers/net/niu.c                       |   16 ++----
 drivers/net/stmmac/stmmac_main.c        |    9 ++--
 drivers/net/usb/ipheth.c                |    7 +--
 drivers/net/via-velocity.c              |    2 +-
 drivers/vhost/vhost.c                   |   80 ++++++++++++++++++++++--------
 include/linux/cgroup.h                  |   11 ++++-
 include/net/cls_cgroup.h                |   10 +++-
 include/net/ip_vs.h                     |    3 +
 include/net/sock.h                      |    1 +
 include/net/udp.h                       |    1 +
 kernel/cgroup.c                         |    9 ++--
 net/core/dev.c                          |   16 +++---
 net/core/skbuff.c                       |    2 +-
 net/ipv4/datagram.c                     |    5 ++-
 net/ipv4/fib_frontend.c                 |   15 +++++-
 net/ipv4/fib_trie.c                     |    8 ++-
 net/ipv4/route.c                        |    7 ++-
 net/ipv4/udp.c                          |   44 +++++++++++++++++
 net/ipv6/datagram.c                     |    7 ++-
 net/ipv6/netfilter/nf_conntrack_reasm.c |   80 ++++++-------------------------
 net/ipv6/reassembly.c                   |   71 ++++++---------------------
 net/ipv6/udp.c                          |   10 ++++
 net/irda/irlan/irlan_common.c           |    2 +-
 net/netfilter/ipvs/ip_vs_core.c         |    1 +
 net/netfilter/ipvs/ip_vs_ftp.c          |    6 --
 net/netfilter/ipvs/ip_vs_xmit.c         |   18 +++++--
 net/sctp/sm_statefuns.c                 |   46 +++++++++---------
 net/unix/af_unix.c                      |   15 +++++-
 39 files changed, 391 insertions(+), 301 deletions(-)
