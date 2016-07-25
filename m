From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 0/5] mlx4 VST QinQ support
Date: Mon, 25 Jul 2016 14:15:31 +0300
Message-ID: <1469445336-21952-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36427 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751139AbcGYLPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 07:15:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset adds VST QinQ support (VLAN protocol 802.1ad)
to the mlx4 driver.
We extended the VF VLAN API with an additional parameter
for VLAN protocol, and kept 802.1Q as drivers' default.

We prepared a userspace support, the patch will be submitted
to the iproute2 mailing list.

The iproute2 VLAN protocol parameter is optional (default: 802.1Q).
A configuration command of VF VLAN that is used prior to this patchset
will result in same functionality as today's (VST without QinQ).

v2:
  Dropped patch 4 ("net/mlx4_core: Add an option to configure SVLAN TPID").
  Patch 1/5: Update commit log.
  2-3/5: Splitted patch 2 into two patches, to separate between changes
         done in mlx4_core and the ones done in mlx4_en.
  4-5/5: Splitted patch 3 into two patches, to separate between the
         addition of a protocol parameter and the actual implementation
	 in mlx4_en.
	 In addition, we implemented a handshake mechanism so PF and VF
	 exchange their VST QinQ support capability.

Moshe Shemesh (5):
  net/mlx4_core: Fix QUERY FUNC CAP flags
  net/mlx4_core: Preparation for VST QinQ
  net/mlx4_en: Preparation for VST QinQ
  net: Update API for VST QinQ support
  net/mlx4: Add VST QinQ support

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |   9 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |   6 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   6 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h           |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   4 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |   5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |   2 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  58 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  23 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            | 129 +++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.h            |   2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   3 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  40 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   6 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |   6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |   2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   5 +-
 drivers/net/ethernet/sfc/sriov.c                   |   5 +-
 drivers/net/ethernet/sfc/sriov.h                   |   2 +-
 include/linux/if_link.h                            |   1 +
 include/linux/mlx4/cmd.h                           |   3 +-
 include/linux/mlx4/device.h                        |   3 +
 include/linux/mlx4/qp.h                            |   2 +
 include/linux/netdevice.h                          |   6 +-
 include/uapi/linux/if_link.h                       |  10 +-
 net/core/rtnetlink.c                               |  28 ++++-
 31 files changed, 346 insertions(+), 53 deletions(-)

-- 
1.8.3.1
