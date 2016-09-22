From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 0/5] mlx4 VF vlan protocol 802.1ad support
Date: Thu, 22 Sep 2016 12:11:11 +0300
Message-ID: <1474535476-10662-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Ariel Elior <ariel.elior@qlogic.com>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Dept-GELinuxNICDev@qlogic.com,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>,
        Tariq Toukan <tariqt@mel
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43199 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753305AbcIVJME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset adds VF VLAN protocol 802.1ad support to the
mlx4 driver.
We extended the VF VLAN API with an additional parameter
for VLAN protocol, and kept 802.1Q as drivers' default.

We prepared a userspace support (ip link tool).
The patch will be submitted to the iproute2 mailing list.

The ip link tool VF VLAN protocol parameter is optional (default: 802.1Q).
A configuration command of VF VLAN that is used prior to this patchset
will result in same functionality as today's (VST with VLAN protocol 802.1Q).

The series generated against net-next commit:
688dc5369a63 "Merge branch 'mlx4-next'"

All maintainers of the modified modules are in cc.

Thanks,
Tariq.

v3:
  Expand the UAPI to a nested list to support future use-cases.
  Use a more formal feature name.

v2:
  Drop patch 4 ("net/mlx4_core: Add an option to configure SVLAN TPID").
  Patch 1/5: Update commit log.
  2-3/5: Split patch 2 into two patches, to separate between changes
         done in mlx4_core and the ones done in mlx4_en.
  4-5/5: Split patch 3 into two patches, to separate between the
         addition of a protocol parameter and the actual implementation
	 in mlx4_en.
	 In addition, we implement a handshake mechanism so PF and VF
	 exchange their VST QinQ support capability.

Moshe Shemesh (5):
  net/mlx4_core: Fix QUERY FUNC CAP flags
  net/mlx4_core: Preparation for VF vlan protocol 802.1ad
  net/mlx4_en: Disable vlan HW acceleration when in VF vlan protocol
    802.1ad mode
  net: Update API for VF vlan protocol 802.1ad support
  net/mlx4: Add VF vlan protocol 802.1ad support

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
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  58 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  19 ++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            | 127 +++++++++++++++++++--
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
 include/uapi/linux/if_link.h                       |  19 ++-
 net/core/rtnetlink.c                               |  80 ++++++++++---
 31 files changed, 388 insertions(+), 66 deletions(-)

-- 
1.8.3.1
