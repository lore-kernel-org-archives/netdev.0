From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 23 May 2011 02:54:27 -0400 (EDT)
Message-ID: <20110523.025427.137762332894556125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, this gets rid of the need to include linux/prefetch.h in
linux/skbuff.h, thanks largely to Part Gortmaker.

1) bnx2x bug sifxes from Vladislav Zolotarov and Dmitry Kravkov.

2) Unicast frame handling fix in macvlan from David Ward.

3) Dave Jones was hitting ip_rt_bug(), add a backtrace so we
   can diagnose it further.

4) Remove some spurious synchronize_{net,rcu}() calls during device
   teardown, from Eric Dumazet.

5) netpoll fixes wrt. bridging from Amerigo Wang.

6) CAIF bug fixes from Sjur Brandeland.

Please pull, thanks a lot!

The following changes since commit 71a8638480eb8fb6cfabe2ee9ca3fbc6e3453a14:

  Merge branch 'viafb-next' of git://github.com/schandinat/linux-2.6 (2011-05-22 12:39:58 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amerigo Wang (4):
      netpoll: disable netpoll when enslave a device
      bridge: call NETDEV_JOIN notifiers when add a slave
      net: rename NETDEV_BONDING_DESLAVE to NETDEV_RELEASE
      rtnetlink: ignore NETDEV_RELEASE and NETDEV_JOIN event

Dave Jones (1):
      ipv4: Give backtrace in ip_rt_bug().

David S. Miller (5):
      net: Remove prefetches from SKB list handlers.
      rionet: Remove pointless printk of skb pointer.
      netlabel: Remove prefetches from list handlers.
      ipv4: Include linux/prefetch.h in fib_trie.c
      net: Remove linux/prefetch.h include from linux/skbuff.h

David Ward (1):
      macvlan: Forward unicast frames in bridge mode to lowerdev

Dmitry Kravkov (2):
      bnx2x: fix DMAE timeout according to hw specifications
      bnx2x: allow device properly initialize after hotplug

Emmanuel Grumbach (1):
      net: skb_trim explicitely check the linearity instead of data_len

Eric Dumazet (2):
      net: remove synchronize_net() from netdev_set_master()
      net: avoid synchronize_rcu() in dev_deactivate_many

Heiko Carstens (1):
      net: filter: move forward declarations to avoid compile warnings

Paul Gortmaker (1):
      drivers/net: add prefetch header for prefetch users

Vladislav Zolotarov (2):
      bnx2x: call dev_kfree_skb_any instead of dev_kfree_skb
      bnx2x: properly handle CFC DEL in cnic flow

WANG Cong (2):
      pktgen: use vzalloc_node() instead of vmalloc_node() + memset()
      pktgen: refactor pg_init() code

sjur.brandeland@stericsson.com (5):
      caif: Bugfix add check NULL pointer before calling functions.
      caif: Fixes freeze on Link layer removal.
      caif: Fix freezes when running CAIF loopback device
      caif: Update documentation of CAIF transmit and receive functions.
      caif: Plug memory leak for checksum error

 drivers/net/benet/be_main.c        |    1 +
 drivers/net/bna/bnad.c             |    1 +
 drivers/net/bnx2x/bnx2x_cmn.c      |    5 +-
 drivers/net/bnx2x/bnx2x_cmn.h      |    2 +-
 drivers/net/bnx2x/bnx2x_main.c     |   72 +++++++++++++----------------------
 drivers/net/bonding/bond_main.c    |    4 +-
 drivers/net/chelsio/sge.c          |    1 +
 drivers/net/cnic.c                 |    1 +
 drivers/net/cxgb3/sge.c            |    1 +
 drivers/net/cxgb4/sge.c            |    1 +
 drivers/net/cxgb4vf/sge.c          |    1 +
 drivers/net/e1000/e1000_main.c     |    1 +
 drivers/net/e1000e/netdev.c        |    1 +
 drivers/net/ehea/ehea_qmr.h        |    1 +
 drivers/net/enic/enic_main.c       |    1 +
 drivers/net/forcedeth.c            |    1 +
 drivers/net/igb/igb_main.c         |    1 +
 drivers/net/igbvf/netdev.c         |    1 +
 drivers/net/ixgb/ixgb_main.c       |    1 +
 drivers/net/ixgbe/ixgbe_main.c     |    1 +
 drivers/net/ixgbevf/ixgbevf_main.c |    1 +
 drivers/net/macvlan.c              |    6 +--
 drivers/net/myri10ge/myri10ge.c    |    1 +
 drivers/net/netconsole.c           |   26 ++++++++----
 drivers/net/pasemi_mac.c           |    1 +
 drivers/net/pch_gbe/pch_gbe_main.c |    1 +
 drivers/net/qla3xxx.c              |    1 +
 drivers/net/qlge/qlge_main.c       |    1 +
 drivers/net/r8169.c                |    1 +
 drivers/net/rionet.c               |    4 +-
 drivers/net/s2io.c                 |    1 +
 drivers/net/sb1250-mac.c           |    1 +
 drivers/net/sfc/rx.c               |    1 +
 drivers/net/skge.c                 |    1 +
 drivers/net/stmmac/stmmac_main.c   |    1 +
 drivers/net/tc35815.c              |    1 +
 drivers/net/vxge/vxge-main.c       |    1 +
 drivers/net/vxge/vxge-traffic.c    |    1 +
 include/linux/filter.h             |    7 ++-
 include/linux/notifier.h           |    3 +-
 include/linux/skbuff.h             |    9 ++--
 include/net/caif/caif_layer.h      |   36 ++++++++++-------
 net/bridge/br_if.c                 |    3 +
 net/caif/caif_dev.c                |    7 +++-
 net/caif/caif_socket.c             |   13 ++----
 net/caif/cfcnfg.c                  |   44 +++++++++------------
 net/caif/cfctrl.c                  |   44 +++++++++++++++------
 net/caif/cfmuxl.c                  |   49 +++++++++++++++++++-----
 net/core/dev.c                     |    4 +-
 net/core/pktgen.c                  |   22 ++++++----
 net/core/rtnetlink.c               |    2 +
 net/ipv4/fib_trie.c                |    1 +
 net/ipv4/route.c                   |    1 +
 net/netlabel/netlabel_addrlist.h   |    8 ++--
 net/sched/sch_generic.c            |   17 +++++++-
 55 files changed, 256 insertions(+), 164 deletions(-)
