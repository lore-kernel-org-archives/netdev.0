From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/6] Intel Wired LAN Driver Updates
Date: Thu, 16 Jan 2014 02:30:04 -0800
Message-ID: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34053 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948AbaAPKae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:30:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

John adds rtnl lock / unlock semantics for ixgbe_reinit_locked()
which was being called without the rtnl lock being held.

Jacob corrects an issue where ixgbevf_qv_disable function does not
set the disabled bit correctly.


>From the community, Wei uses a type of struct for pci driver-specific
data in ixgbevf_suspend()

Don changes the way we store ring arrays in a manner that allows 
support of multiple queues on multiple nodes and creates new ring
initialization functions for work previously done across multiple
functions - making the code closer to ixgbe and hopefully more readable.
He also fixes incorrect fiber eeprom write logic. 

John Fastabend (1):
  ixgbe: reinit_locked() should be called with rtnl_lock

Jacob Keller (1):
  ixgbevf: set the disable state when ixgbevf_qv_disable is called

Wei Yongjun (1):
  ixgbevf: use pci drvdata correctly in ixgbevf_suspend()

Don Skidmore (3):
  ixgbevf: Convert ring storage form pointer to an array to array of
    pointers
  ixgbevf: create function for all of ring init
  ixgbe: Fix incorrect logic for fixed fiber eeprom write

 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   2 +
 drivers/net/ethernet/intel/ixgbevf/defines.h      |  17 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  30 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   5 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 431 ++++++++++++----------
 6 files changed, 274 insertions(+), 213 deletions(-)

-- 
1.8.5.GIT
