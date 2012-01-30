From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 30 Jan 2012 13:22:11 -0500 (EST)
Message-ID: <20120130.132211.963897536330834856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Setting link attributes can modify the size of the attributes
   that would be reported on a subsequent getlink netlink operation,
   therefore min_ifinfo_dump_size needs to be adjusted.  From
   Stefan Gula.

2) Resegmentation of TSO frames while trimming can violate invariants
   expected by callers, namely that the number of segments can only
   stay the same or decrease, never increase.  If MSS changes, however,
   we can trim data but then end up with more segments.  Fix this by
   only segmenting to the MSS already recorded in the SKB.  That's
   the simplest fix for now and if we want to get more fancy in the
   future that's a more involved change.

   This probably explains some retransmit counter inaccuracies.

   From Neal Cardwell.

3) Fix too-many-wakeups in POLL with AF_UNIX sockets, from Eric Dumazet.

4) Fix CAIF crashes wrt. namespace handling.  From Eric Dumazet and
   Eric W. Biederman.

5) TCP port selection fixes from Flavio Leitner.

6) More socket memory cgroup build fixes in certain randonfig situations.
   From Glauber Costa.

7) Fix TCP memory sysctl regression reported by Ingo Molnar, also from
   Glauber Costa.

Please pull, thanks a lot!

The following changes since commit 0a9626575400879d1d5e6bc8768188b938d7c501:

  Merge tag 'driver-core-3.3-rc1-bugfixes' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core (2012-01-28 18:20:48 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

Eliad Peller (2):
      mac80211: update oper_channel on ibss join
      mac80211: set bss_conf.idle when vif is connected

Eric Dumazet (2):
      netns: fix net_alloc_generic()
      af_unix: fix EPOLLET regression for stream sockets

Eric W. Biederman (2):
      netns: Fail conspicously if someone uses net_generic at an inappropriate time.
      net caif: Register properly as a pernet subsystem.

Flavio Leitner (2):
      tcp: bind() fix autoselection to share ports
      tcp: bind() optimize port allocation

Glauber Costa (2):
      net: explicitly add jump_label.h header to sock.h
      net/tcp: Fix tcp memory limits initialization when !CONFIG_SYSCTL

James Chapman (1):
      l2tp: l2tp_ip - fix possible oops on packet receive

Johannes Berg (1):
      iwlwifi: fix PCI-E transport "inta" race

Neal Cardwell (1):
      tcp: fix tcp_trim_head() to adjust segment count with skb MSS

Stefan Gula (1):
      net: RTNETLINK adjusting values of min_ifinfo_dump_size

Wei Liu (1):
      xen-netfront: correct MAX_TX_TARGET calculation.

Willem de Bruijn (1):
      ipv6: Fix ip_gre lockless xmits.

 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c |    4 +-
 drivers/net/xen-netfront.c                       |    2 +-
 include/net/netns/generic.h                      |    1 +
 include/net/sock.h                               |    1 +
 include/net/tcp.h                                |    2 +
 net/caif/caif_dev.c                              |   22 +--------------
 net/caif/cfcnfg.c                                |    1 -
 net/core/net_namespace.c                         |   31 +++++++++++----------
 net/core/rtnetlink.c                             |    3 ++
 net/ipv4/inet_connection_sock.c                  |    7 +++-
 net/ipv4/ip_gre.c                                |    4 +++
 net/ipv4/sysctl_net_ipv4.c                       |    1 +
 net/ipv4/tcp.c                                   |   16 +++++++++--
 net/ipv4/tcp_output.c                            |    6 +---
 net/l2tp/l2tp_ip.c                               |    5 ---
 net/mac80211/ibss.c                              |    1 +
 net/mac80211/iface.c                             |    1 +
 net/unix/af_unix.c                               |   19 +++----------
 18 files changed, 59 insertions(+), 68 deletions(-)
