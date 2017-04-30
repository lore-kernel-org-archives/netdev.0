From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/11][pull request] 10GbE Intel Wired LAN Driver Updates 2017-04-29
Date: Sat, 29 Apr 2017 20:07:59 -0700
Message-ID: <20170430030810.56415-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34650 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969694AbdD3DIP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Apr 2017 23:08:15 -0400
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

v2: fixed up patches #2 and #3 based on feedback from Jakub and to
    address build issues when page sizes are larger than 4k

The following are changes since commit 4c042a80c1776477d8f13d0b214809a2eaedf01d:
  Merge branch 'bpf-misc-next'
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |  75 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 477 +++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 135 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   8 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  53 ++-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |   5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  33 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c           |   6 +-
 12 files changed, 701 insertions(+), 154 deletions(-)

-- 
2.12.2
