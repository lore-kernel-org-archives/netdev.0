From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 01 May 2015 22:43:31 -0400 (EDT)
Message-ID: <20150501.224331.1013896468656746295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbEBCnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 22:43:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Receive packet length needs to be adjust by 2 on RX to accomodate
   the two padding bytes in altera_tse driver.  From Vlastimil Setka.

2) If rx frame is dropped due to out of memory in macb driver, we
   leave the receive ring descriptors in an undefined state.  From
   Punnaiah Choudary Kalluri

3) Some netlink subsystems erroneously signal NLM_F_MULTI.  That is
   only for dumps.  Fix from Nicolas Dichtel.

4) Fix mis-use of raw rt->rt_pmtu value in ipv4, one must always go
   via the ipv4_mtu() helper.  From Herbert Xu.

5) Fix null deref in bridge netfilter, and miscalculated lengths in
   jump/goto nf_tables verdicts.  From Florian Westphal.

6) Unhash ping sockets properly.

7) Software implementation of BPF divide did 64/32 rather than 64/64
   bit divide.  The JITs got it right.  Fix from Alexei Starovoitov.

Please pull, thanks a lot!

The following changes since commit 2decb2682f80759f631c8332f9a2a34a02150a03:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-04-27 14:05:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to a134f083e79fb4c3d0a925691e732c56911b4326:

  ipv4: Missing sk_nulls_node_init() in ping_unhash(). (2015-05-01 22:02:47 -0400)

----------------------------------------------------------------
Alexei Starovoitov (1):
      bpf: fix 64-bit divide

Antonio Ospite (2):
      trivial: net: atl1e: atl1e_hw.h: fix 0x0x prefix
      trivial: net: systemport: bcmsysport.h: fix 0x0x prefix

Benjamin Poirier (2):
      mlx4: Fix tx ring affinity_mask creation
      mlx4_en: Use correct loop cursor in error path.

David Ahern (1):
      net/mlx4_core: Fix unaligned accesses

David S. Miller (3):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'bnx2x'
      ipv4: Missing sk_nulls_node_init() in ping_unhash().

Florian Westphal (3):
      netfilter: nf_tables: fix wrong length for jump/goto verdicts
      netfilter: bridge: fix NULL deref in physin/out ifindex helpers
      net: sched: act_connmark: don't zap skb->nfct

Guenter Roeck (1):
      net: dsa: Fix scope of eeprom-length property

Hariprasad Shenai (1):
      cxgb4: Fix MC1 memory offset calculation

Herbert Xu (1):
      route: Use ipv4_mtu instead of raw rt_pmtu

Ido Shamay (1):
      net/mlx4_en: Schedule napi when RX buffers allocation fails

Jon Paul Maloy (1):
      tipc: fix problem with parallel link synchronization mechanism

KY Srinivasan (1):
      hv_netvsc: Fix a bug in netvsc_start_xmit()

Karicheri, Muralidharan (1):
      net: netcp: remove call to netif_carrier_(on/off) for MAC to Phy interface

Markus Pargmann (1):
      net: fec: Fix RGMII-ID mode

Michal Schmidt (3):
      bnx2x: mark LRO as a fixed disabled feature if disable_tpa is set
      bnx2x: merge fp->disable_tpa with fp->mode
      bnx2x: remove {TPA,GRO}_ENABLE_FLAG

Nicolas Dichtel (3):
      bridge/mdb: remove wrong use of NLM_F_MULTI
      bridge/nl: remove wrong use of NLM_F_MULTI
      tipc: remove wrong use of NLM_F_MULTI

Pai (1):
      net: Fix Kernel Panic in bonding driver debugfs file: rlb_hash_table

Punnaiah Choudary Kalluri (1):
      net: macb: Fix race condition in driver when Rx frame is dropped

Simon Xiao (1):
      hv_netvsc: introduce netif-msg into netvsc module

Tony Camuso (1):
      netxen_nic: use spin_[un]lock_bh around tx_clean_lock

Vlastimil Setka (1):
      altera_tse: Correct rx packet length

Yuval Mintz (1):
      bnx2x: Delay during kdump load

 drivers/net/bonding/bond_main.c                    | 10 ++++
 drivers/net/ethernet/altera/altera_tse_main.c      |  6 ++
 drivers/net/ethernet/atheros/atl1e/atl1e_hw.h      |  2 +-
 drivers/net/ethernet/broadcom/bcmsysport.h         |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    | 67 +++++++++-------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 17 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c   |  2 +-
 drivers/net/ethernet/cadence/macb.c                |  3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |  5 +-
 drivers/net/ethernet/freescale/fec_main.c          |  5 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  7 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         | 26 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  8 ++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            | 18 ++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |  1 +
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |  4 +-
 drivers/net/ethernet/rocker/rocker.c               |  5 +-
 drivers/net/ethernet/ti/netcp_ethss.c              |  8 ++-
 drivers/net/hyperv/hyperv_net.h                    | 13 ++++-
 drivers/net/hyperv/netvsc.c                        |  8 +--
 drivers/net/hyperv/netvsc_drv.c                    | 47 +++++++--------
 drivers/net/hyperv/rndis_filter.c                  |  3 +-
 include/linux/netdevice.h                          |  6 +-
 include/linux/netfilter_bridge.h                   | 16 +++++-
 include/linux/rtnetlink.h                          |  2 +-
 kernel/bpf/core.c                                  | 12 ++--
 net/bridge/br_mdb.c                                |  2 +-
 net/bridge/br_netlink.c                            |  4 +-
 net/bridge/br_private.h                            |  2 +-
 net/core/rtnetlink.c                               | 12 ++--
 net/dsa/dsa.c                                      |  2 +-
 net/ipv4/ping.c                                    |  1 +
 net/ipv4/route.c                                   |  5 +-
 net/netfilter/nf_tables_api.c                      |  3 +-
 net/sched/act_connmark.c                           |  2 -
 net/tipc/bearer.c                                  | 17 +++---
 net/tipc/link.c                                    | 15 ++---
 42 files changed, 224 insertions(+), 159 deletions(-)
