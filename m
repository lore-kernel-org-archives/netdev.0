From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 18 Jan 2016 14:06:11 -0500 (EST)
Message-ID: <20160118.140611.1142601589580634102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix brcmfmac build with older gcc, from Arend van Spriel.

2) IRQ values unintentionally truncated to u8 in mlx5 driver, from
   Doron Tsur.

3) Fix build warnings wrt. tcp cgroup changes, from Geert Uytterhoeven.

4) Limit deep recursion in ovs stack, from Hannes Frederic Sowa.

5) at803x phy driver bug fixes from, Martin Blumenstingl.

6) Fix TSO handling in hns driver, from Daode Huang.

Please pull, thanks a lot!

The following changes since commit 4e5448a31d73d0e944b7adb9049438a09bc332cb:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-01-15 13:33:12 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git 

for you to fetch changes up to b064d0d88ae5280c7e878f79d0c9a8e2876a4d14:

  ovs: limit ovs recursions in ovs_execute_actions to not corrupt stack (2016-01-18 12:09:45 -0500)

----------------------------------------------------------------
Arend van Spriel (1):
      brcmfmac: fix BRCMF_FW_NVRAM_DEF macro for older gcc compilers

David S. Miller (1):
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge

Doron Tsur (1):
      net/mlx5_core: Fix trimming down IRQ number

Geert Uytterhoeven (1):
      tcp_memcontrol: Forward declare cgroup_subsys and mem_cgroup stucts

Hannes Frederic Sowa (1):
      ovs: limit ovs recursions in ovs_execute_actions to not corrupt stack

Ido Schimmel (1):
      team: Replace rcu_read_lock with a mutex in team_vlan_rx_kill_vid

Ivan Vecera (1):
      bna: fix Rx data corruption with VLAN stripping enabled and MTU > 4096

Martin Blumenstingl (4):
      net: phy: at803x: Don't set gbit features for the AR8030 phy
      net: phy: at803x: Allow specifying the RGMII RX clock delay via phy mode
      net: phy: at803x: Clean up duplicate register definitions
      net: phy: at803x: Add the interrupt register bit definitions

Sven Eckelmann (8):
      batman-adv: Avoid recursive call_rcu for batadv_bla_claim
      batman-adv: Avoid recursive call_rcu for batadv_nc_node
      batman-adv: Drop immediate batadv_orig_ifinfo free function
      batman-adv: Drop immediate batadv_neigh_node free function
      batman-adv: Drop immediate batadv_hardif_neigh_node free function
      batman-adv: Drop immediate neigh_ifinfo free function
      batman-adv: Drop immediate batadv_hard_iface free function
      batman-adv: Drop immediate orig_node free function

Xin Long (1):
      sctp: the temp asoc's transports should not be hashed/unhashed

Zi Shen Lim (2):
      arm64: insn: remove BUG_ON from codegen
      arm64: bpf: add extra pass to handle faulty codegen

huangdaode (1):
      net: hns: bug fix about hisilicon TSO BD mode

 arch/arm64/kernel/insn.c                                    | 165 ++++++++++++++++++++++++++++++++++++++++++---------------------
 arch/arm64/net/bpf_jit_comp.c                               |  22 ++++++++-
 drivers/infiniband/hw/mlx5/cq.c                             |   2 +-
 drivers/net/ethernet/brocade/bna/bnad.c                     |  37 +++++++++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c           |  13 ++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h           |   3 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h           |   5 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c           |   6 +--
 drivers/net/ethernet/mellanox/mlx5/core/main.c              |   3 +-
 drivers/net/phy/at803x.c                                    | 110 ++++++++++++++++++++++++++++++++----------
 drivers/net/team/team.c                                     |   6 +--
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.h |   3 +-
 include/linux/mlx5/cq.h                                     |   2 +-
 include/linux/mlx5/driver.h                                 |   5 +-
 include/net/tcp_memcontrol.h                                |   3 ++
 net/batman-adv/bridge_loop_avoidance.c                      |  10 ++--
 net/batman-adv/hard-interface.h                             |  12 -----
 net/batman-adv/network-coding.c                             |  19 ++++----
 net/batman-adv/originator.c                                 | 196 +++++++++++++++++++++++++++------------------------------------------------
 net/batman-adv/originator.h                                 |   1 -
 net/batman-adv/translation-table.c                          |  28 +++++------
 net/openvswitch/actions.c                                   |  19 ++++++--
 net/sctp/endpointola.c                                      |   2 +-
 net/sctp/input.c                                            |   8 +++-
 24 files changed, 395 insertions(+), 285 deletions(-)
