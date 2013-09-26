From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/4][RFC] Lockdep enablement for seqcount/seqlocks
Date: Thu, 26 Sep 2013 11:34:20 -0700
Message-ID: <1380220464-28840-1-git-send-email-john.stultz@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roger Luethi <rl@hellgate.ch>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Jesse Gross <jesse@nicira.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wanted to send this out again for feedback.

This patch series enables lockdep for seqcount/seqlock structures,
as well as provides the required cleanups to explicitly initialize
the seqcount structures on u64_stat_sync users.

In addition the last two patches in this provide naive fixes to
some of the issues the new lockdep infrastructure caught.

I'd greatly appreciate any thoughts or feedback on the series!

thanks
-john

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Mirko Lindner <mlindner@marvell.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Roger Luethi <rl@hellgate.ch>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Jesse Gross <jesse@nicira.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org


John Stultz (4):
  [RFC] net: Explicitly initialize u64_stats_sync structures for lockdep
  [RFC] seqcount: Add lockdep functionality to seqcount/seqlock
    structures
  [RFC] cpuset: Fix potential deadlock w/ set_mems_allowed
  [RFC] ipv6: Fix for possible ipv6 seqlock deadlock

 arch/x86/vdso/vclock_gettime.c                 |  8 +--
 drivers/net/dummy.c                            |  6 ++
 drivers/net/ethernet/emulex/benet/be_main.c    |  4 ++
 drivers/net/ethernet/intel/igb/igb_main.c      |  5 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  4 ++
 drivers/net/ethernet/marvell/mvneta.c          |  3 +
 drivers/net/ethernet/marvell/sky2.c            |  3 +
 drivers/net/ethernet/neterion/vxge/vxge-main.c |  4 ++
 drivers/net/ethernet/nvidia/forcedeth.c        |  2 +
 drivers/net/ethernet/realtek/8139too.c         |  3 +
 drivers/net/ethernet/tile/tilepro.c            |  2 +
 drivers/net/ethernet/via/via-rhine.c           |  3 +
 drivers/net/ifb.c                              |  5 ++
 drivers/net/loopback.c                         |  6 ++
 drivers/net/macvlan.c                          |  7 +++
 drivers/net/nlmon.c                            |  8 +++
 drivers/net/team/team.c                        |  6 ++
 drivers/net/team/team_mode_loadbalance.c       |  9 ++-
 drivers/net/veth.c                             |  8 +++
 drivers/net/virtio_net.c                       |  8 +++
 drivers/net/vxlan.c                            |  8 +++
 drivers/net/xen-netfront.c                     |  6 ++
 fs/dcache.c                                    |  4 +-
 fs/fs_struct.c                                 |  2 +-
 include/linux/cpuset.h                         |  4 ++
 include/linux/init_task.h                      |  8 +--
 include/linux/lockdep.h                        |  8 ++-
 include/linux/seqlock.h                        | 79 ++++++++++++++++++++++++--
 include/linux/u64_stats_sync.h                 |  7 +++
 mm/filemap_xip.c                               |  2 +-
 net/8021q/vlan_dev.c                           |  9 ++-
 net/bridge/br_device.c                         |  7 +++
 net/ipv4/af_inet.c                             | 14 +++++
 net/ipv4/ip_tunnel.c                           |  8 ++-
 net/ipv6/addrconf.c                            | 14 +++++
 net/ipv6/af_inet6.c                            | 14 +++++
 net/ipv6/ip6_gre.c                             | 15 +++++
 net/ipv6/ip6_output.c                          |  7 ++-
 net/ipv6/ip6_tunnel.c                          |  7 +++
 net/ipv6/sit.c                                 | 15 +++++
 net/netfilter/ipvs/ip_vs_ctl.c                 | 25 +++++++-
 net/openvswitch/datapath.c                     |  6 ++
 net/openvswitch/vport.c                        |  8 +++
 43 files changed, 354 insertions(+), 27 deletions(-)

-- 
1.8.1.2


