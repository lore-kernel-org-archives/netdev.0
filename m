From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates 2015-04-11
Date: Sat, 11 Apr 2015 12:07:47 -0700
Message-ID: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15376 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042AbbDKTH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to iflink, ixgbe and ixgbevf.

The entire set of changes come from Vlad Zolotarov to ultimately add
the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS random key.

Currently we support only 82599 and x540 devices.  On those devices, VFs
share the RSS redirection table and hash key with a PF.  Letting the VF
query this information may introduce some security risks, therefore this
feature will be disabled by default.

The new netdev op allows a system administrator to change the default
behaviour with "ip link set" command.  The relevant iproute2 patch has
already been sent and awaits for this series upstream.

The following are changes since commit 5288ec157cf1d1bf7cfa3581f958b1812a37fec9:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Vlad Zolotarov (9):
  ixgbe: Refactor the RSS configuration code
  ixgbe: Add the appropriate ethtool ops to query RSS indirection table
    and key
  if_link: Add an additional parameter to ifla_vf_info for RSS querying
  ixgbe: Add a new netdev op to allow/prevent a VF from querying an RSS
    info
  ixgbe: Add a RETA query command to VF-PF channel API
  ixgbevf: Add a RETA query code
  ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
  ixgbevf: Add RSS Key query code
  ixgbevf: Add the appropriate ethtool ops to query RSS indirection
    table and key

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  11 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  42 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 152 +++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  90 ++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   2 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  69 ++++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   5 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |   5 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 124 ++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
 include/linux/if_link.h                           |   1 +
 include/linux/netdevice.h                         |   8 ++
 include/uapi/linux/if_link.h                      |   8 ++
 net/core/rtnetlink.c                              |  32 ++++-
 16 files changed, 505 insertions(+), 53 deletions(-)

-- 
1.9.3
