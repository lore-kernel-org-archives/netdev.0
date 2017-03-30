From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 0/7] i40e: Add port representor and initial switchdev support
Date: Wed, 29 Mar 2017 17:22:48 -0700
Message-ID: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25988 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752253AbdC3AW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:22:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Patch 1 introduces devlink interface to get/set the mode of switch.
- Patch 2 adds support to create control plane port representor netdevs
  associated with dataplane PF and VFs that can be used to control/configure
  PF/VFs even when they are in a different namespace.
- Patch 3 enables syncing link state between PF/VFs and associated Port
  representors.
- Patch 4 adds a new type to metadata_dst to allow passing port id to lower
  device.
- Patch 5 adds TX and RX support to port netdevs.
- Patch 6 enables HW and SW Port statistics to be exposed via netlink on
  Port netdevs.
- Patch 7 adds support to get switch id and port number for Port netdevs.

v6:
- Port representor netdevs are created and supported for PFs too.
- Broadcast filters are not disabled by default on VFs in switchdev mode.
  Instead, offload_fwd_mark is set on skb's that are forwarded to Port
  netdevs to indicate that the HW has done the forwarding.
- Random mac addresses are assigned to Port netdevs.
v5:
- Fix an issue with the link state sync patch.
v4:
- Make VFPR ndo_get_stats64 a void function to match with recent upstream
  change.
v3:
- misc. error handling fixes suggested by Scott Peterson
- introduce switchdev_ops and add support to get switch id and port no.
  for VFPR netdevs. Suggested by Or Gerlitz
v2:
- handle i40e_alloc_vfpr_netdev() failures.
- minor comment/commit msg updates.

Jakub Kicinski (1):
  net: store port/representator id in metadata_dst

Sridhar Samudrala (6):
  i40e: Introduce devlink interface
  i40e: Introduce Port Representor netdevs and switchdev mode.
  i40e: Sync link state between PF/VFs and Port representor netdevs
  i40e: Add TX and RX support over port netdev's in switchdev mode
  i40e: Add support for exposing switch port statistics via port netdevs
  i40e: Add support to get switch id and port number for port netdevs

 drivers/net/ethernet/intel/Kconfig                 |   1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  37 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 609 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 170 +++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  34 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   7 +
 include/net/dst_metadata.h                         |  41 +-
 net/core/dst.c                                     |  15 +-
 net/core/filter.c                                  |   1 +
 net/ipv4/ip_tunnel_core.c                          |   6 +-
 net/openvswitch/flow_netlink.c                     |   4 +-
 13 files changed, 899 insertions(+), 31 deletions(-)

-- 
1.8.3.1
