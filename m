From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 08 Jun 2015 17:33:08 -0700 (PDT)
Message-ID: <20150608.173308.1510279540043938154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbbFIAdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 20:33:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix stack allocation in s390 BPF JIT, from Michael Holzheu.

2) Disable LRO on openvswitch paths, from Jiri Benc.

3) UDP early demux doesn't handle multicast group membership
   properly, fix from Shawn Bohrer.

4) Fix TX queue hang due to incorrect handling of mixed sized fragments
   and linearlization in i40e driver, from Anjali Singhai Jain.

5) Cannot use disable_irq() in timer handler of AMD xgbe driver, from
   Thomas Lendacky.

6) b2net driver improperly assumes pci_alloc_consistent() gives zero'd
   out memory, use dma_zalloc_coherent().  From Sriharsha Basavapatna.

7) Fix use-after-free in MPLS and ipv6, from Robert Shearman.

8) Missing neif_napi_del() calls in cleanup paths of b44 driver, from
   Hauke Mehrtens.

Please pull, thanks a lot!

The following changes since commit c46a024ea5eb0165114dbbc8c82c29b7bcf66e71:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-06-01 20:51:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to bbbf2df0039d31c6a0a9708ce4fe220a54bd5379:

  net: replace last open coded skb_orphan_frags with function call (2015-06-08 12:15:13 -0700)

----------------------------------------------------------------
Anjali Singhai Jain (3):
      i40e/i40evf: Fix mixed size frags and linearization
      i40e: start up in VEPA mode by default
      i40e: Make sure to be in VEB mode if SRIOV is enabled at probe

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-queue
      Revert "bridge: use _bh spinlock variant for br_fdb_update to avoid lockup"

Florian Fainelli (1):
      net: bcmgenet: power on MII block for all MII modes

Hauke Mehrtens (2):
      rhashtable: add missing import <linux/export.h>
      b44: call netif_napi_del()

Jiri Benc (1):
      openvswitch: disable LRO

Josh Hunt (1):
      ipv6: Fix protocol resubmission

Lendacky, Thomas (1):
      amd-xgbe: Use disable_irq_nosync from within timer function

Michael Holzheu (2):
      s390/bpf: fix stack allocation
      s390/bpf: fix bpf frame pointer setup

Nikolay Aleksandrov (1):
      bridge: disable softirqs around br_fdb_update to avoid lockup

Robert Shearman (2):
      mpls: fix possible use after free of device
      ipv6: fix possible use after free of dev stats

Shawn Bohrer (1):
      ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()

Sriharsha Basavapatna (1):
      be2net: Replace dma/pci_alloc_coherent() calls with dma_zalloc_coherent()

Willem de Bruijn (1):
      net: replace last open coded skb_orphan_frags with function call

Wilson Kok (1):
      bridge: use _bh spinlock variant for br_fdb_update to avoid lockup

 arch/s390/net/bpf_jit.h                            |  4 +++-
 arch/s390/net/bpf_jit_comp.c                       | 11 ++++++----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  2 +-
 drivers/net/ethernet/broadcom/b44.c                |  2 ++
 drivers/net/ethernet/broadcom/genet/bcmmii.c       | 12 ++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.c        | 87 ++++++++++++++++++++++++++++++++++++++++++++---------------------------------
 drivers/net/ethernet/emulex/benet/be_ethtool.c     | 18 +++++++++-------
 drivers/net/ethernet/emulex/benet/be_main.c        | 15 +++++++-------
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  9 ++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 35 +++++++++++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 25 +++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 ++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 25 +++++++++-------------
 lib/rhashtable.c                                   |  1 +
 net/bridge/br_fdb.c                                |  2 ++
 net/core/dev.c                                     | 11 ++--------
 net/ipv4/udp.c                                     | 18 +++++++++++++---
 net/ipv6/addrconf_core.c                           | 11 ++++++++--
 net/ipv6/ip6_input.c                               |  8 ++++---
 net/mpls/af_mpls.c                                 |  2 +-
 net/mpls/internal.h                                |  1 +
 net/openvswitch/vport-netdev.c                     |  1 +
 23 files changed, 196 insertions(+), 115 deletions(-)
