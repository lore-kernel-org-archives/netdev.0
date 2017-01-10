From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v3 PATCH 0/7]i40e: Add VF Port Representator support for SR-IOV VFs
Date: Mon,  9 Jan 2017 16:59:43 -0800
Message-ID: <1484009990-3018-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, scott.d.peterson@intel.com,
        gerlitz.or@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:18951 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755084AbdAJA7y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 19:59:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is against dev-queue branch of Jeff Kirsher's next-queue git tree.

- Patch 1 introduces devlink interface to get/set the mode of SRIOV switch.
- Patch 2 adds support to create VF port representor(VFPR) netdevs associated
  with SR-IOV VFs that can be used to control/configure VFs from PF name space.
- Patch 3 enables syncing link state between VFs and VFPRs.
- Patch 4 adds a new type to metadata_dst to allow passing VF id to lower device.
- Patch 5 adds TX and RX support to VFPR netdevs.
- Patch 6 enables HW and SW VFPR statistics to be exposed via netlink on VFPR
  netdevs.
- Patch 7 adds support to get switch id and port number for VFPR netdevs.


Sridhar Samudrala (7):
  i40e: Introduce devlink interface.
  i40e: Introduce VF Port Representator(VFPR) netdevs.
  i40e: Sync link state between VFs and VFPRs
  net: store port/representator id in metadata_dst
  i40e: Add TX and RX support in switchdev mode.
  i40e: Add support for exposing VF port statistics via VFPR netdev on
    the host.
  i40e: Add support to get switch id and port number for VFPR netdevs

 drivers/net/ethernet/intel/Kconfig                 |   1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   5 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 131 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 146 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 370 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  25 ++
 include/net/dst_metadata.h                         |  41 ++-
 net/core/dst.c                                     |  15 +-
 net/core/filter.c                                  |   1 +
 net/ipv4/ip_tunnel_core.c                          |   6 +-
 net/openvswitch/flow_netlink.c                     |   4 +-
 13 files changed, 715 insertions(+), 35 deletions(-)

-- 
2.5.5
