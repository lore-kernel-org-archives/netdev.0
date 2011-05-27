From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 27 May 2011 14:10:40 -0400 (EDT)
Message-ID: <20110527.141040.977259448309758762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Last networking pull request for this merge window:

1) Fix build regressions in some configurations due to the ratelimited
   WARN interfaces, reported by Ingo.

   And Ingo also pointed out the ugly ratelimit.h dependency that
   linux/net.h has, get rid of that too.

2) Fix races that cause ugly crashes in inetpeer cleanups, from Eric
   Dumazet.

3) Namespace fix in IPVS from Hans Schillstrom.

4) ipset bug fixes from Jozsef Kadlecsik, mostly return code correction=
s
   and fixing timeout comparisons with jiffies.

5) ->set_features vs. ->set_flags compatability would accidently trunca=
te
   flag values down to a bool, fix from Micha=A9=A9 Miros=A9=A9aw.

6) Missing %pK conversions in CAN socket layer from Oliver Hartkopp.

Please pull, thanks a lot!

The following changes since commit a74b81b0aff4a01e0816df5915c854fb52c5=
e87f:

  Merge branch 'linux-next' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/jlbec/ocfs2 (2011-05-26 10:55:15 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andy Gospodarek (1):
      bonding: cleanup module option descriptions

Dan Williams (1):
      atm: expose ATM device index in sysfs

David Miller (1):
      netfilter: Fix several warnings in compat_mtw_from_user().

David S. Miller (5):
      bug.h: Move ratelimit warn interfaces to ratelimit.h
      Merge branch 'pablo/nf-2.6-updates' of git://1984.lsi.us.es/net-2=
=2E6
      net: Kill ether_table[] declaration.
      net: Add linux/sysctl.h includes where needed.
      net: Kill ratelimit.h dependency in linux/net.h

Eric Dumazet (1):
      inetpeer: fix race in unused_list manipulations

Hans Schillstrom (1):
      IPVS: bug in ip_vs_ftp, same list heaad used in all netns.

Johan Hovold (1):
      net: davinci_emac: fix dev_err use at probe

Jozsef Kadlecsik (3):
      netfilter: ipset: Use proper timeout value to jiffies conversion
      netfilter: ipset: remove unused variable from type_pf_tdel()
      netfilter: ipset: fix ip_set_flush return code

Justin Mattock (1):
      net:8021q:vlan.c Fix pr_info to just give the vlan fullname and v=
ersion.

Micha=A9=A9 Miros=A9=A9aw (1):
      net: fix ETHTOOL_SFEATURES compatibility with old ethtool_ops.set=
_flags

Oliver Hartkopp (1):
      can: convert to %pK for kptr_restrict support

 drivers/net/bonding/bond_main.c                |   34 ++++++++++++----=
---
 drivers/net/davinci_emac.c                     |   22 ++++++------
 include/asm-generic/bug.h                      |   40 ----------------=
------
 include/linux/if_ether.h                       |    4 --
 include/linux/net.h                            |    6 ---
 include/linux/netfilter.h                      |    1 +
 include/linux/netfilter/ipset/ip_set_ahash.h   |    4 +-
 include/linux/netfilter/ipset/ip_set_timeout.h |   18 ++++++----
 include/linux/ratelimit.h                      |   40 ++++++++++++++++=
++++++
 include/net/ip_vs.h                            |    3 +-
 include/net/net_namespace.h                    |    1 +
 include/net/net_ratelimit.h                    |    8 ++++
 net/8021q/vlan.c                               |    5 +--
 net/atm/atm_sysfs.c                            |   10 ++++++
 net/bridge/netfilter/ebtables.c                |    6 ++-
 net/can/proc.c                                 |    7 ++--
 net/core/ethtool.c                             |   25 +++++++++++++-
 net/core/filter.c                              |    1 +
 net/core/sysctl_net_core.c                     |    1 +
 net/core/utils.c                               |    1 +
 net/ipv4/inetpeer.c                            |   42 +++++++++++++++-=
-------
 net/netfilter/ipset/ip_set_core.c              |    2 +-
 net/netfilter/ipvs/ip_vs_ftp.c                 |   27 +++++++++++----
 23 files changed, 189 insertions(+), 119 deletions(-)
 create mode 100644 include/net/net_ratelimit.h
