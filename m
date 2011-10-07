From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Fri,  7 Oct 2011 00:18:32 -0700
Message-ID: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754Ab1JGHSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000, e1000e, igb and ixgbe.  Here
is a quick summary:
  - e1000: 3 conversions (timers->threads, mdelay->msleep, mutex->rtnl)
  - e1000e: fix jumbo frames on 82579
  - igb: several cleanups to reduce stack space and improve performance
  - ixgbe: bump driver ver

The following are changes since commit e878d78b9a7403fabc89ecc93c56928b74d14f01:
  virtio-net: Verify page list size before fitting into skb
and are available in the git repository at
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (8):
  igb: Make Tx budget for NAPI user adjustable
  igb: split buffer_info into tx_buffer_info and rx_buffer_info
  igb: Consolidate creation of Tx context descriptors into a single
    function
  igb: Make first and tx_buffer_info->next_to_watch into pointers
  igb: Create separate functions for generating cmd_type and olinfo
  igb: Cleanup protocol handling in transmit path
  igb: Combine all flag info fields into a single tx_flags structure
  igb: consolidate creation of Tx buffer info and data descriptor

Bruce Allan (1):
  e1000e: bad short packets received when jumbos enabled on 82579

Don Skidmore (1):
  ixgbe: bump version number

Jesse Brandeburg (3):
  e1000: convert hardware management from timers to threads
  e1000: convert mdelay to msleep
  e1000: convert to private mutex from rtnl

 drivers/net/ethernet/intel/e1000/e1000.h      |   12 +-
 drivers/net/ethernet/intel/e1000/e1000_hw.c   |   22 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c |  169 +++---
 drivers/net/ethernet/intel/e1000e/ich8lan.c   |    2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h  |    2 +
 drivers/net/ethernet/intel/igb/igb.h          |   54 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c  |   16 +-
 drivers/net/ethernet/intel/igb/igb_main.c     |  840 ++++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +-
 9 files changed, 600 insertions(+), 521 deletions(-)

-- 
1.7.6.4
