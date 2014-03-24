From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [RFC v2 0/1]: Add minimum bandwidth support in IP tool.
Date: Mon, 24 Mar 2014 00:57:52 -0400
Message-ID: <1395637073-29794-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>, <ben@decadent.org.uk>,
	<gregory.v.rose@intel.com>, <linux-net-drivers@solarflare.com>,
	<Ariel.Elior@qlogic.com>, <amirv@mellanox.com>, <mkubecek@suse.cz>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51089 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbaCXFek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 01:34:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today IP tool allows configuring only maximum bandwidth.
Likewise minimum bandwidth can also be configured for a VF. It puts
lower limit on the VF bandwidth. VF is guaranteed to have a bandwidth
of at least this value.

With this change, user can alter minimum bandwidth rate.

This patch series has 1 combined patch that adds required support in kernel
and qlcnic driver changes for minimum bandwidth support.

This change also requires changes in IP tool. I am sending that patch
separately.

Changes in v2 per suggestions from Ben Hutchings and Michal Kubecek:

   net patch:
        o Fixed enum index for IFLA_VF_RATE
        o ndo_set_vf_rate replaces ndo_set_vf_tx_rate. Drivers that currently implement
          ndo_set_vf_tx_rate is converted to implement ndo_set_vf_rate instead.
        o If only IFLA_VF_TX_RATE is specified, the core should get the current minimum
          before calling ndo_set_vf_rate.
        o IFLA_VF_RATE should override if both IFLA_VF_RATE and IFLA_VF_TX_RATE are specified.
        o Combined qlcnic patch to add support for minimum bandwidth with net patch


Please comment.

Thanks,
Sucheta.

Sucheta Chakraborty (1):
  net: Add support to configure SR-IOV VF minimum and maximum Tx
    rate through ip tool.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |  3 +-
 drivers/net/ethernet/emulex/benet/be_main.c        | 23 ++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  6 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          | 20 +++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 13 ++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |  3 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           | 11 +++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |  2 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 52 +++++++++++++++------
 drivers/net/ethernet/sfc/siena_sriov.c             |  3 +-
 include/linux/if_link.h                            |  3 +-
 include/linux/netdevice.h                          |  8 ++--
 include/uapi/linux/if_link.h                       |  9 +++-
 net/core/rtnetlink.c                               | 53 +++++++++++++++++++---
 20 files changed, 159 insertions(+), 61 deletions(-)
