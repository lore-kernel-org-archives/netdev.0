From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 31 Jul 2012 15:30:58 -0700 (PDT)
Message-ID: <20120731.153058.165173940800330723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think Eric Dumazet and I have dealt with all of the known routing
cache removal fallout.  Some other minor fixes all around.

1) Fix RCU of cached routes, particular of output routes which
   require liberation via call_rcu() instead of call_rcu_bh().
   From Eric Dumazet.

2) Make sure we purge net device references in cached routes
   properly.

3) TG3 driver bug fixes from Michael Chan.

4) Fix reported 'expires' value in ipv6 routes, from Li Wei.

5) TUN driver ioctl leaks kernel bytes to userspace, from
   Mathias Krause.

Please pull, thanks a lot.

The following changes since commit f7da9cdf45cbbad5029d4858dcbc0134e06084ed:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-07-28 06:00:39 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to caacf05e5ad1abf0a2864863da4e33024bc68ec6:

  ipv4: Properly purge netdev references on uncached routes. (2012-07-31 15:06:50 -0700)

----------------------------------------------------------------
David S. Miller (3):
      tun: Fix formatting.
      ipv4: Cache routes in nexthop exception entries.
      ipv4: Properly purge netdev references on uncached routes.

Devendra Naga (2):
      bnx2x: remove cast around the kmalloc in bnx2x_prev_mark_path
      seeq: use PTR_RET at init_module of driver

Eric Dumazet (5):
      net: TCP early demux cleanup
      net: ipv4: fix RCU races on dst refcounts
      ipv4: remove rt_cache_rebuild_count
      ipv4: Restore old dst_free() behavior.
      ipv4: percpu nh_rth_output cache

Karsten Keil (1):
      mISDN: Bugfix only few bytes are transfered on a connection

Li Wei (1):
      ipv6: fix incorrect route 'expires' value passed to userspace

Lin Ming (2):
      ipv4: fix debug info in tnode_new
      ipv4: clean up put_child

Mathias Krause (1):
      net/tun: fix ioctl() based info leaks

Michael Chan (5):
      tg3: Request APE_LOCK_PHY before PHY access
      tg3: Fix Read DMA workaround for 5719 A0.
      tg3: Add New 5719 Read DMA workaround
      tg3: Fix race condition in tg3_get_stats64()
      tg3: Update version to 3.124

brenohl@br.ibm.com (1):
      qlge: Add offload features to vlan interfaces

stephen hemminger (1):
      bridge: make port attributes const

 Documentation/networking/ip-sysctl.txt           |   6 --
 drivers/isdn/hardware/mISDN/avmfritz.c           |   7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   3 +-
 drivers/net/ethernet/broadcom/tg3.c              |  71 +++++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h              |   8 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c     |   1 +
 drivers/net/ethernet/seeq/seeq8005.c             |   4 +-
 drivers/net/tun.c                                |   6 +-
 include/net/inet_sock.h                          |   9 +++
 include/net/ip_fib.h                             |   6 +-
 include/net/netns/ipv4.h                         |   2 -
 include/net/route.h                              |   3 +
 net/bridge/br_sysfs_if.c                         |   6 +-
 net/core/rtnetlink.c                             |   8 +-
 net/ipv4/fib_frontend.c                          |   1 +
 net/ipv4/fib_semantics.c                         |  42 +++++++++-
 net/ipv4/fib_trie.c                              |  53 ++++++-------
 net/ipv4/ip_input.c                              |   2 -
 net/ipv4/route.c                                 | 183 +++++++++++++++++++++++++++++++------------
 net/ipv4/sysctl_net_ipv4.c                       |  11 ---
 net/ipv4/tcp_input.c                             |   3 +-
 net/ipv4/tcp_ipv4.c                              |  12 +--
 net/ipv4/tcp_minisocks.c                         |   3 +-
 net/ipv4/xfrm4_policy.c                          |   1 +
 net/ipv6/ip6_input.c                             |   2 -
 net/ipv6/route.c                                 |   8 +-
 26 files changed, 316 insertions(+), 145 deletions(-)
