From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] 10GbE Intel Wired LAN Driver Updates 2017-04-20
Date: Thu, 20 Apr 2017 18:50:18 -0700
Message-ID: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48798 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034324AbdDUBup (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:50:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only, most notable is
the addition of XDP support to our 10GbE drivers.

Paul fixes ixgbe to acquire the PHY semaphore before accessing PHY
registers when issuing a device reset.

John adds XDP support (yeah!) for ixgbe.

Emil fixes an issue by flushing the MACVLAN filters on VF reset to avoid
conflicts with other VFs that may end up using the same MAC address.  Also
fixed a bug where ethtool -S displayed some empty fields for ixgbevf
because it was using ixgbe_stats instead ixgbevf_stats for
IXGBEVF_QUEUE_STATS_LEN.

Tony adds the ability to specify a zero MAC address in order to clear the
VF's MAC address from the RAR table.  Also adds support for a new
1000Base-T device based on x550EM_X MAC type.  Fixed an issue where the
RSS key specified by the user would be over-written with a pre-existing
value, so change the rss_key to a pointer so we can check to see if the
key has a value set before attempting to set it.  Fixed the logic for
mailbox support for getting RETA and RSS values, which are only supported
by 82599 and x540 devices.

The following are changes since commit 6905e5a5c8d552ace1d65cacb43499a0eb1e0b89:
  net/mlx5e: IPoIB, Fix error handling in mlx5_rdma_netdev_alloc()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Emil Tantilov (2):
  ixgbe: clean macvlan MAC filter table on VF reset
  ixgbevf: fix size of queue stats length

John Fastabend (3):
  ixgbe: add XDP support for pass and drop actions
  ixgbe: add support for XDP_TX action
  ixgbe: delay tail write to every 'n' packets

Paul Greenwalt (2):
  ixgbe: Acquire PHY semaphore before device reset
  ixgbe: Add 1000Base-T device based on X550EM_X MAC

Tony Nguyen (4):
  ixgbe: Allow setting zero MAC address for VF
  ixgbe: Check for RSS key before setting value
  ixgbevf: Fix errors in retrieving RETA and RSS from PF
  ixgbevf: Check for RSS key before setting value

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  27 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  33 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |  78 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 472 +++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 135 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   8 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  53 ++-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  33 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   6 +-
 12 files changed, 701 insertions(+), 152 deletions(-)

-- 
2.12.2
