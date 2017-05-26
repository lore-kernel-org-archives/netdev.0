From: David Miller <davem@redhat.com>
Subject: [GIT] Networking
Date: Fri, 26 May 2017 15:50:27 -0400 (EDT)
Message-ID: <20170526.155027.1992869174501854056.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix state pruning in bpf verifier wrt. alignment, from Daniel
   Borkmann.

2) Handle non-linear SKBs properly in SCTP ICMP parsing, from
   Davide Caratti.

3) Fix bit field definitions for rss_hash_type of descriptors in
   mlx5 driver, from Jesper Brouer.

4) Defer slave->link updates until bonding is ready to do a full
   commit to the new settings, from Nithin Sujir.

5) Properly reference count ipv4 FIB metrics to avoid use after
   free situations, from Eric Dumazet and several others including
   Cong Wang and Julian Anastasov.

6) Fix races in llc_ui_bind(), from Lin Zhang.

7) Fix regression of ESP UDP encapsulation for TCP packets, from
   Steffen Klassert.

8) Fix mdio-octeon driver Kconfig deps, from Randy Dunlap.

9) Fix regression in setting DSCP on ipv6/GRE encapsulation, from
   Peter Dawson.

Please pull, thanks a lot!

The following changes since commit fadd2ce5a3680fb265694f573cbfb8bcb7d6c9d5:

  Merge tag 'pstore-v4.12-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux (2017-05-22 19:31:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 3fb07daff8e99243366a081e5129560734de4ada:

  ipv4: add reference counting to metrics (2017-05-26 14:57:07 -0400)

----------------------------------------------------------------
Alexander Potapenko (1):
      net: rtnetlink: bail out from rtnl_fdb_dump() on parse error

Andrew Lunn (1):
      net: phy: marvell: Limit errata to 88m1101

Antony Antony (1):
      xfrm: fix state migration copy replay sequence numbers

Arend Van Spriel (1):
      cfg80211: make cfg80211_sched_scan_results() work from atomic context

Daniel Borkmann (5):
      bpf: fix incorrect pruning decision when alignment must be tracked
      bpf: properly reset caller saved regs after helper call and ld_abs/ind
      bpf: add bpf_clone_redirect to bpf_helper_changes_pkt_data
      bpf: fix wrong exposure of map_flags into fdinfo for lpm
      bpf: add various verifier test cases

David Daney (1):
      test_bpf: Add a couple of tests for BPF_JSGE.

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'sctp-dupcookie-fixes'
      Merge tag 'mac80211-for-davem-2017-05-23' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'mlx5-fixes-2017-05-23' of git://git.kernel.org/.../saeed/linux
      Merge branch 'q-in-q-checksums'
      Merge branch 'bpf-fixes'

Davide Caratti (1):
      sctp: fix ICMP processing if skb is non-linear

Erez Shitrit (1):
      net/mlx5e: IPoIB, handle RX packet correctly

Eric Dumazet (1):
      ipv4: add reference counting to metrics

Eric Garver (1):
      geneve: fix fill_info when using collect_metadata

Gustavo A. R. Silva (1):
      net: fix potential null pointer dereference

Ihar Hrachyshka (1):
      arp: fixed -Wuninitialized compiler warning

Ilan Tayari (1):
      xfrm: Fix NETDEV_DOWN with IPSec offload

Jesper Dangaard Brouer (1):
      mlx5: fix bug reading rss_hash_type from CQE

Mohamad Haj Yahia (1):
      net/mlx5: Avoid using pending command interface slots

Nithin Sujir (1):
      bonding: Don't update slave->link until ready to commit

Oliver Neukum (1):
      cdc-ether: divorce initialisation with a filter reset and a generic method

Or Gerlitz (5):
      net/mlx5e: Use the correct delete call on offloaded TC encap entry detach
      net/sched: act_csum: Add accessors for offloading drivers
      net/mlx5e: Allow TC csum offload if applied together with pedit action
      net/mlx5e: Properly enforce disallowing of partial field re-write offload
      net/mlx5e: Fix warnings around parsing of TC pedit actions

Peter Dawson (1):
      ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets

Quentin Schulz (1):
      net: fec: add post PHY reset delay DT property

Rajkumar Manoharan (1):
      mac80211: strictly check mesh address extension mode

Randy Dunlap (1):
      net/phy: fix mdio-octeon dependency and build

Roman Kapl (1):
      net: move somaxconn init from sysctl code

Sabrina Dubroca (1):
      xfrm: fix stack access out of bounds with CONFIG_XFRM_SUB_POLICY

Steffen Klassert (2):
      esp4: Fix udpencap for local TCP packets.
      af_key: Fix slab-out-of-bounds in pfkey_compile_policy.

Tariq Toukan (1):
      net/mlx5: Tolerate irq_set_affinity_hint() failures

Uwe Kleine-König (1):
      net: ethernet: ax88796: don't call free_irq without request_irq first

Vlad Yasevich (3):
      vlan: Fix tcp checksum offloads in Q-in-Q vlans
      be2net: Fix offload features for Q-in-Q packets
      virtio-net: enable TSO/checksum offloads for Q-in-Q vlans

Wei Wang (1):
      tcp: avoid fastopen API to be used on AF_UNSPEC

Xin Long (2):
      sctp: fix stream update when processing dupcookie
      sctp: set new_asoc temp when processing dupcookie

linzhang (1):
      net: llc: add lock_sock in llc_ui_bind to avoid a race condition

 Documentation/devicetree/bindings/net/fsl-fec.txt |   4 ++
 drivers/net/bonding/bond_main.c                   |  11 ++++-
 drivers/net/ethernet/8390/ax88796.c               |   7 +---
 drivers/net/ethernet/emulex/benet/be_main.c       |   4 +-
 drivers/net/ethernet/freescale/fec_main.c         |  16 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c     |  41 +++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   8 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  60 ++++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/eq.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  15 ++-----
 drivers/net/geneve.c                              |   8 ++--
 drivers/net/gtp.c                                 |   2 +-
 drivers/net/phy/Kconfig                           |   2 +-
 drivers/net/phy/marvell.c                         |  66 ++++++++++++++++-------------
 drivers/net/usb/cdc_ether.c                       |  31 ++++++++++----
 drivers/net/virtio_net.c                          |   1 +
 include/linux/filter.h                            |  10 +++++
 include/linux/if_vlan.h                           |  18 ++++----
 include/linux/mlx5/device.h                       |  10 ++++-
 include/linux/mlx5/driver.h                       |   7 +++-
 include/linux/usb/usbnet.h                        |   1 +
 include/net/dst.h                                 |   8 +++-
 include/net/ip_fib.h                              |  10 ++---
 include/net/tc_act/tc_csum.h                      |  15 +++++++
 include/net/xfrm.h                                |  10 -----
 kernel/bpf/arraymap.c                             |   1 +
 kernel/bpf/lpm_trie.c                             |   1 +
 kernel/bpf/stackmap.c                             |   1 +
 kernel/bpf/verifier.c                             |  56 ++++++++++++-------------
 lib/test_bpf.c                                    |  38 +++++++++++++++++
 net/core/dst.c                                    |  23 +++++++----
 net/core/filter.c                                 |   1 +
 net/core/net_namespace.c                          |  19 +++++++++
 net/core/rtnetlink.c                              |   7 +++-
 net/core/sysctl_net_core.c                        |   2 -
 net/ipv4/arp.c                                    |   2 +-
 net/ipv4/esp4.c                                   |   5 ++-
 net/ipv4/fib_semantics.c                          |  17 ++++----
 net/ipv4/route.c                                  |  10 ++++-
 net/ipv4/tcp.c                                    |   7 +++-
 net/ipv6/ip6_gre.c                                |  13 +++---
 net/ipv6/ip6_tunnel.c                             |  21 ++++++----
 net/key/af_key.c                                  |   2 +-
 net/llc/af_llc.c                                  |   3 ++
 net/mac80211/rx.c                                 |   3 +-
 net/sctp/associola.c                              |   4 +-
 net/sctp/input.c                                  |  16 +++----
 net/sctp/sm_make_chunk.c                          |  13 ++----
 net/sctp/sm_statefuns.c                           |   3 ++
 net/wireless/scan.c                               |   8 ++--
 net/wireless/util.c                               |  10 +++--
 net/xfrm/xfrm_device.c                            |   2 +-
 net/xfrm/xfrm_policy.c                            |  47 ---------------------
 net/xfrm/xfrm_state.c                             |   2 +
 tools/include/linux/filter.h                      |  10 +++++
 tools/testing/selftests/bpf/test_verifier.c       | 239 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 57 files changed, 701 insertions(+), 254 deletions(-)
