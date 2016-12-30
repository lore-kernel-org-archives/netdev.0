From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [net-next PATCH 0/6] i40e: Add VF port representator support or SR-IOV VFs
Date: Thu, 29 Dec 2016 22:20:57 -0800
Message-ID: <1483078863-22026-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10017 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750794AbcL2V2J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 16:28:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Patch 1 introduces devlink interface to get/set the mode of SRIOV switch.
- Patch 2 adds support to create VF port representor(VFPR) netdevs associated
  with SR-IOV VFs that can be used to control/configure VFs from PF name space.
- Patch 3 enables syncing link state between VFs and VFPRs.
- Patch 4 adds a new type to metadata_dst to allow passing VF id to lower device.
- Patch 5 adds TX and RX support to VFPR netdevs.
- Patch 6 enables HW and SW VFPR statistics to be exposed via netlink on VFPR
  netdevs.

Jakub Kicinski (1):
  net: store port/representator id in metadata_dst

Sridhar Samudrala (5):
  i40e: Introduce devlink interface.
  i40e: Introduce VF Port Representator(VFPR) netdevs.
  i40e: Sync link state between VFs and VFPRs
  i40e: Add TX and RX support in switchdev mode.
  i40e: Add support for exposing VF port statistics via VFPR netdev on
    the host.

 drivers/net/ethernet/intel/Kconfig                 |   1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  96 +++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 132 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 321 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  25 ++
 include/net/dst_metadata.h                         |  35 ++-
 net/core/dst.c                                     |  15 +-
 net/core/filter.c                                  |   1 +
 net/ipv4/ip_tunnel_core.c                          |   6 +-
 net/openvswitch/flow_netlink.c                     |   4 +-
 13 files changed, 610 insertions(+), 34 deletions(-)

-- 
2.5.5
