From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 10 Jan 2014 15:31:14 -0500 (EST)
Message-ID: <20140110.153114.750803296050700850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42471 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758228AbaAJUbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 15:31:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Famouse last words: "final pull request" :-)

I'm sending this because Jason Wang's fixes are pretty important.

1) Add missing per-cpu stats initialization to ip6_vti.  Otherwise
   lockdep spits out a call trace.  From Li RongQing.

2) Fix NULL oops in wireless hwsim, from Javier Lopez.

3) TIPC deferred packet queue unlink must NULL out skb->next to
   avoid crashes.  From Erik Hugne.

4) Fix access to uninitialized buffer in nf_nat netfilter code, from
   Daniel Borkmann.

5) Fix lifetime of ipv6 loopback and SIT tunnel addresses, otherwise
   they basically timeout immediately.  From Hannes Frederic Sowa.

6) Fix DMA unmapping of TSO packets in bnx2x driver, from Michal Schmidt.

7) Do not allow L2 forwarding offload via macvtap device, the way things
   are now it will not end up being forwaded at all.  From Jason Wang.

8) Fix transmit queue selection via ndo_dfwd_start_xmit(), fixing things
   like applying NETIF_F_LLTX to the wrong device (!!) and eliding the
   proper transmit watchdog handling.

9) qlcnic driver was not updating tx statistics at all, from Manish Chopra.

Please pull, thanks a lot!

The following changes since commit ef350bb7c5e0748f7d17f1d70c6b0eec5f64f446:

  Merge tag 'ext4_for_linus_stable' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2014-01-07 08:22:42 +0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to d6e9c89a8d3cf0a5184badbcd50169179af27721:

  qlcnic: Fix ethtool statistics length calculation (2014-01-10 13:25:29 -0500)

----------------------------------------------------------------
Arron Wang (1):
      NFC: Fix target mode p2p link establishment

Daniel Borkmann (1):
      netfilter: nf_nat: fix access to uninitialized buffer in IRC NAT helper

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Erik Hugne (1):
      tipc: correctly unlink packets from deferred packet queue

Felix Fietkau (1):
      mac80211: move "bufferable MMPDU" check to fix AP mode scan

Hannes Frederic Sowa (1):
      ipv6: add link-local, sit and loopback address with INFINITY_LIFE_TIME

Jason Wang (2):
      macvlan: forbid L2 fowarding offload for macvtap
      net: core: explicitly select a txq before doing l2 forwarding

Javier Lopez (1):
      mac80211_hwsim: Fix NULL pointer dereference

Jesper Dangaard Brouer (1):
      netfilter: only warn once on wrong seqadj usage

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'nfc-fixes-3.13-1' of git://git.kernel.org/.../sameo/nfc-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Li RongQing (1):
      ipv6: pcpu_tstats.syncp should be initialised in ip6_vti.c

Manish Chopra (1):
      qlcnic: Fix bug in TX statistics

Michal Schmidt (1):
      bnx2x: fix DMA unmapping of TSO split BDs

Oren Givon (1):
      iwlwifi: add new devices for 7265 series

Shahed Shaikh (1):
      qlcnic: Fix ethtool statistics length calculation

Yuval Mintz (1):
      bnx2x: prevent WARN during driver unload

 drivers/net/bonding/bond_main.c                     |  3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         | 44 ++++++++++++++++++++++++++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     | 28 +++++++++++++++-------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |  3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 33 +++++++++++++--------------------
 drivers/net/ethernet/lantiq_etop.c                  |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c          |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h        |  3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 41 ++++++++++++++++++++++-------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    |  3 +++
 drivers/net/ethernet/tile/tilegx.c                  |  3 ++-
 drivers/net/macvlan.c                               | 14 +++++++-------
 drivers/net/team/team.c                             |  3 ++-
 drivers/net/tun.c                                   |  3 ++-
 drivers/net/wireless/iwlwifi/pcie/drv.c             | 10 ++++++++--
 drivers/net/wireless/mac80211_hwsim.c               |  2 +-
 drivers/net/wireless/mwifiex/main.c                 |  3 ++-
 drivers/staging/bcm/Bcmnet.c                        |  3 ++-
 drivers/staging/netlogic/xlr_net.c                  |  3 ++-
 drivers/staging/rtl8188eu/os_dep/os_intfs.c         |  3 ++-
 include/linux/netdevice.h                           | 12 ++++++++----
 net/core/dev.c                                      | 29 +++++++++++++++++------------
 net/core/flow_dissector.c                           | 10 +++++++---
 net/core/netpoll.c                                  |  2 +-
 net/ipv6/addrconf.c                                 |  6 ++++--
 net/ipv6/ip6_vti.c                                  |  6 ++++++
 net/mac80211/iface.c                                |  6 ++++--
 net/mac80211/tx.c                                   | 23 +++++++++++++----------
 net/netfilter/nf_conntrack_seqadj.c                 |  2 +-
 net/netfilter/nf_nat_irc.c                          | 32 +++++++++++++++++++++++++++-----
 net/nfc/core.c                                      |  2 +-
 net/sched/sch_generic.c                             |  2 +-
 net/tipc/link.c                                     |  1 +
 34 files changed, 219 insertions(+), 126 deletions(-)
