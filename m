From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [net-next 0/1]: Add minimum bandwidth support in IP tool.
Date: Thu, 22 May 2014 09:59:04 -0400
Message-ID: <1400767145-11564-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	<ben@decadent.org.uk>, <gregory.v.rose@intel.com>,
	<linux-net-drivers@solarflare.com>, <Ariel.Elior@qlogic.com>,
	<amirv@mellanox.com>, <mkubecek@suse.cz>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:26400 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830AbaEVO2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 10:28:41 -0400
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

   net-next patch:
        o Fixed enum index for IFLA_VF_RATE
        o ndo_set_vf_rate replaces ndo_set_vf_tx_rate. Drivers that currently implement
          ndo_set_vf_tx_rate is converted to implement ndo_set_vf_rate instead.
        o If only IFLA_VF_TX_RATE is specified, the core should get the current minimum
          before calling ndo_set_vf_rate.
        o IFLA_VF_RATE should override if both IFLA_VF_RATE and IFLA_VF_TX_RATE are specified.
        o Combined qlcnic patch to add support for minimum bandwidth with net-next patch

Changes in v3 as per suggestions from Ben Hutchings

    net-next patch:
        o If user enters only one value out of min_tx_rate or max_tx_rate, the other
          value will be read back in userspace for IFLA_VF_RATE.

        o For IFLA_VF_TX_RATE, min rate will still be read in kernel space to preserve
          compatibility:
          (a) between old tool sends "rate" and kernel is new (expects "min" and "max")
          (b) or, when new tool sends only "rate" and kernel is old (expects only "rate")

Change in v4 as per suggestions from Stephen Hemminger:

     No change in net-next patch. Change in Iproute patch w.r.t display of min_tx_rate and max_tx_rate.

Please apply to net-next.

Thanks,
Sucheta.

Sucheta Chakraborty (1):
  net: Add support to configure SR-IOV VF minimum and maximum Tx
    rate through ip tool.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c  |    3 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   21 +++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   26 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |    3 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   20 +++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |   13 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    3 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   11 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov.h  |    2 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   52 ++++++++++++++------
 drivers/net/ethernet/sfc/siena_sriov.c             |    3 +-
 include/linux/if_link.h                            |    3 +-
 include/linux/netdevice.h                          |    8 ++-
 include/uapi/linux/if_link.h                       |    9 +++-
 net/core/rtnetlink.c                               |   38 ++++++++++++--
 20 files changed, 156 insertions(+), 67 deletions(-)
