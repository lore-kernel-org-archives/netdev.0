From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 23 Feb 2017 13:56:42 -0500 (EST)
Message-ID: <20170223.135642.1921502853248933574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Some 'const'ing in qlogic networking drivers, from Bhumika Goyal.

2) Fix scheduling while atomic in l2tp network namespace exit by deferring
   the work to the workqueue.  From Ridge Kennedy.

3) Fix use after free in dccp timewait handling, from Andrey Ryabinin.

4) mlx5e CQE compression engine not initialized properly, from Tariq
   Toukan.

5) Some UAPI header fixes from Dmitry V. Levin.

6) Don't overwrite module parameter value in mlx4 driver, from Majd
   Dibbiny.

7) Fix divide by zero in xt_hashlimit netfilter module, from Alban
   Browaeys.

Please pull, thanks a lot!

The following changes since commit ca78d3173cff3503bcd15723b049757f75762d15:

  Merge tag 'arm64-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux (2017-02-22 10:46:44 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 9c4713701c01e4cef6e2315c2818abc919ffb0de:

  bpf: Fix bpf_xdp_event_output (2017-02-23 13:53:42 -0500)

----------------------------------------------------------------
Alban Browaeys (1):
      netfilter: xt_hashlimit: Fix integer divide round to zero.

Alexey Kodanev (2):
      tcp: setup timestamp offset when write_seq already set
      tcp: account for ts offset only if tsecr not zero

Andrey Ryabinin (1):
      net/dccp: fix use after free in tw_timer_handler()

Bhumika Goyal (2):
      qlogic: qlcnic_sysfs: constify bin_attribute structures
      qlogic: netxen: constify bin_attribute structures

Christian Lamparter (1):
      net: emac: add support for device-tree based PHY discovery and setup

Colin Ian King (1):
      bpf: fix spelling mistake: "proccessed" -> "processed"

David S. Miller (3):
      Merge branch 'mlx5-fixes'
      Merge branch 'mlx4-misc-fixes'
      Merge git://git.kernel.org/.../pablo/nf

Dmitry V. Levin (5):
      uapi: fix linux/if.h userspace compilation errors
      uapi: fix linux/ip6_tunnel.h userspace compilation errors
      uapi: fix linux/llc.h userspace compilation error
      uapi: fix linux/seg6.h and linux/seg6_iptunnel.h userspace compilation errors
      uapi: fix linux/rds.h userspace compilation errors

Eric Dumazet (1):
      net/mlx4_en: Use __skb_fill_page_desc()

Eugenia Emantayev (1):
      net/mlx4: Spoofcheck and zero MAC can't coexist

Jack Morgenstein (1):
      net/mlx4_core: Use cq quota in SRIOV when creating completion EQs

Jiri Kosina (1):
      netfilter: nf_ct_helper: warn when not applying default helper assignment

Jiri Pirko (1):
      lib: Remove string from parman config selection

Jozsef Kadlecsik (1):
      Fix bug: sometimes valid entries in hash:* types of sets were evicted

Ken-ichirou MATSUZAWA (1):
      netfilter: nfnetlink_queue: fix NFQA_VLAN_MAX definition

Kevin Cernekee (2):
      netfilter: ctnetlink: Fix regression in CTA_STATUS processing
      netfilter: ctnetlink: Fix regression in CTA_HELP processing

Liping Zhang (1):
      netfilter: nfnetlink: remove static declaration from err_list

Majd Dibbiny (1):
      net/mlx4_core: Fix VF overwrite of module param which disables DMFS on new probed PFs

Martin KaFai Lau (1):
      bpf: Fix bpf_xdp_event_output

Mohamad Haj Yahia (1):
      net/mlx5e: s390 system compilation fix

Or Gerlitz (1):
      net/mlx4: Change ENOTSUPP to EOPNOTSUPP

Pablo Neira Ayuso (1):
      Merge branch 'master' of git://blackhole.kfki.hu/nf

Ridge Kennedy (1):
      l2tp: Avoid schedule while atomic in exit_net

Saeed Mahameed (2):
      net/mlx5e: Register/unregister vport representors on interface attach/detach
      net/mlx5e: Update MPWQE stride size when modifying CQE compress state

Tariq Toukan (3):
      net/mlx5e: Do not reduce LRO WQE size when not using build_skb
      net/mlx5e: Fix broken CQE compression initialization
      net/mlx5e: Fix wrong CQE decompression

Vishwanath Pai (1):
      netfilter: ipset: Null pointer exception in ipset list:set

Zhu Yanjun (1):
      forcedeth: Remove return from a void function

 drivers/net/ethernet/ibm/emac/Kconfig                 |   1 +
 drivers/net/ethernet/ibm/emac/core.c                  | 254 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/ibm/emac/core.h                  |   4 ++
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |  22 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c        |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |   6 +--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c            |   8 ++--
 drivers/net/ethernet/mellanox/mlx4/eq.c               |   5 +--
 drivers/net/ethernet/mellanox/mlx4/fw.c               |   2 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c             |   2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c             |  11 +++--
 drivers/net/ethernet/mellanox/mlx4/mr.c               |   2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c               |   2 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     |  40 +++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c       |  15 +++----
 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c |   1 +
 drivers/net/ethernet/nvidia/forcedeth.c               |   2 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c  |   6 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c     |  16 +++----
 include/linux/mlx4/cmd.h                              |   2 +-
 include/linux/mlx4/driver.h                           |  10 +++++
 include/uapi/linux/if.h                               |   4 ++
 include/uapi/linux/ip6_tunnel.h                       |   2 +
 include/uapi/linux/llc.h                              |   1 +
 include/uapi/linux/netfilter/nf_conntrack_common.h    |   4 ++
 include/uapi/linux/netfilter/nfnetlink_queue.h        |   2 +-
 include/uapi/linux/rds.h                              |  10 ++---
 include/uapi/linux/seg6.h                             |   1 +
 include/uapi/linux/seg6_iptunnel.h                    |   2 +
 kernel/bpf/verifier.c                                 |   2 +-
 lib/Kconfig                                           |   2 +-
 net/core/filter.c                                     |   4 +-
 net/dccp/ipv4.c                                       |   6 +++
 net/dccp/ipv6.c                                       |   6 +++
 net/ipv4/tcp_ipv4.c                                   |  16 ++++---
 net/ipv4/tcp_minisocks.c                              |   3 +-
 net/ipv6/tcp_ipv6.c                                   |  16 ++++---
 net/l2tp/l2tp_core.c                                  |   4 +-
 net/netfilter/ipset/ip_set_hash_gen.h                 |   2 +-
 net/netfilter/ipset/ip_set_list_set.c                 |   9 ++--
 net/netfilter/nf_conntrack_helper.c                   |  39 ++++++++++++------
 net/netfilter/nf_conntrack_netlink.c                  |  43 ++++++++++++++++---
 net/netfilter/nfnetlink.c                             |   2 +-
 net/netfilter/xt_hashlimit.c                          |  25 ++++-------
 47 files changed, 489 insertions(+), 133 deletions(-)
