From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/7] Intel Wired LAN Driver Updates
Date: Tue,  7 Jan 2014 23:40:40 -0800
Message-ID: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15337 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919AbaAHHkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 02:40:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains add Live Error Recovery (LER) support to the ixgbe
driver. This support also improves behavior in Thunderbolt environments.
This involves checking all register reads for a value of all ones and when
that is seen, to read the status register, which should never properly
return all ones, to confirm whether the received value was correct. When
this detects a removal, the hw_addr field is cleared to indicate the
removal.  This then blocks subsequent access to the device registers.

All register access macros have been changed to static inline functions
and all register accesses now use them.

The __IXGBE_DOWN bit is no longer overloaded to also mean that device
removal has been initiated. Now the bit can be used to protect ixgbe_down
from multiple entry via test_and_set_bit. A needed smp_mb__before_clear_bit
was also added.

Mark Rustad (7):
  1/7 ixbge: Protect ixgbe_down with __IXGBE_DOWN bit
  2/7 ixgbe: Indicate removal state explicitly
  3/7 ixgbe: Use static inlines instead of macros
  4/7 ixgbe: Make ethtool register test use accessors
  5/7 ixgbe: Check register reads for adapter removal
  6/7 ixgbe: Check for adapter removal on register writes
  7/7 ixgbe: Additional adapter removal checks

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   7 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  55 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 110 +++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  74 ++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   2 +-
 6 files changed, 180 insertions(+), 71 deletions(-)

-- 
1.8.5.GIT
