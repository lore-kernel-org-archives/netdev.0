From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Sat,  8 Mar 2014 01:25:26 -0800
Message-ID: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39895 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbaCHJZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, ixgbevf and igb.

Majority of this series contains fixes and cleanups to e1000e,
most notably are:

Todd provides a fix to PTP in e1000e which adds a lock in e1000e_phc_adjfreq
to prevent concurrent changes to TIMINCA and SYSTIMH/L.  Then provides an
igb fix to use ARRAY_SIZE for array size calculation.

David provides the remaining e1000e which contain:
 - cleanup of pointer references that are no longer used
 - fix an issue on systems with Management Engine enabled with the
   ethernet cable unplugged
 - fix an issue on 82579 where enabling EEE LPI sooner than one second
   after link up causes link issues on some switches
 - refactor the power management flows to prevent the suspend path from
   being executed twice when hibernating
 - refactor the runtime power management to fix interfering with the
   functionality of Energy Efficient Ethernet when enabled and to fix
   the device from repeatedly flip between suspend and resume with the
   interface administratively downed
 - enable the feature PHY Ultra Low Power Mode which is a power saving
   feature that reduces the power consumption of the PHY when a cable is
   not connected
 - fix the ethtool offline tests for 82579 parts
 - fix SHRA register access for 82579 parts which was introduced by
   previous commit c3a0dce35af0 "e1000e: fix overrun of PHY RAR array"

Florian provides a fix for ixgbevf where skb->pkt_type was being checked
like a bitmask, but it is not a bitmask.

Fix an issue reported by Stephen Hemminger where there was a warning
about code defined but never used if IGB_HWMON is not defined.

The following are changes since commit 37147652cfaa20a87ead9bb04aec1834b40c5c97:
  6lowpan: reassembly: fix return of init function
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

David Ertman (11):
  e1000e: Cleanup unecessary references
  e1000e: Resolve issues with Management Engine (ME) briefly blocking
    PHY resets
  e1000e: Fix 82579 sets LPI too early.
  e1000e: Cleanup - Update GPL header and Copyright
  e1000e: Add missing branding strings in ich8lan.c
  e1000e: Refactor PM flows
  e1000e Refactor of Runtime Power Management
  e1000e: Feature Enable PHY Ultra Low Power Mode (ULP)
  e1000e: Fix not generating an error on invalid load parameter
  e1000e: Fix ethtool offline tests for 82579 parts
  e1000e: Fix SHRA register access for 82579

Florian Fainelli (1):
  ixgbevf: fix skb->pkt_type checks

Jeff Kirsher (1):
  igb: fix warning if !CONFIG_IGB_HWMON

Todd Fujinaka (2):
  e1000e: PTP lock in e1000e_phc_adjustfreq
  igb: fix array size calculation

 drivers/net/ethernet/intel/e1000e/80003es2lan.c   |  47 +--
 drivers/net/ethernet/intel/e1000e/80003es2lan.h   |  47 +--
 drivers/net/ethernet/intel/e1000e/82571.c         |  47 +--
 drivers/net/ethernet/intel/e1000e/82571.h         |  47 +--
 drivers/net/ethernet/intel/e1000e/Makefile        |   7 +-
 drivers/net/ethernet/intel/e1000e/defines.h       |  55 ++-
 drivers/net/ethernet/intel/e1000e/e1000.h         |  50 ++-
 drivers/net/ethernet/intel/e1000e/ethtool.c       |  63 ++--
 drivers/net/ethernet/intel/e1000e/hw.h            |  55 +--
 drivers/net/ethernet/intel/e1000e/ich8lan.c       | 427 ++++++++++++++++++----
 drivers/net/ethernet/intel/e1000e/ich8lan.h       |  72 ++--
 drivers/net/ethernet/intel/e1000e/mac.c           |  47 +--
 drivers/net/ethernet/intel/e1000e/mac.h           |  47 +--
 drivers/net/ethernet/intel/e1000e/manage.c        |  47 +--
 drivers/net/ethernet/intel/e1000e/manage.h        |  47 +--
 drivers/net/ethernet/intel/e1000e/netdev.c        | 286 +++++++++------
 drivers/net/ethernet/intel/e1000e/nvm.c           |  47 +--
 drivers/net/ethernet/intel/e1000e/nvm.h           |  47 +--
 drivers/net/ethernet/intel/e1000e/param.c         |  53 ++-
 drivers/net/ethernet/intel/e1000e/phy.c           |  47 +--
 drivers/net/ethernet/intel/e1000e/phy.h           |  47 +--
 drivers/net/ethernet/intel/e1000e/ptp.c           |  52 ++-
 drivers/net/ethernet/intel/e1000e/regs.h          |  48 ++-
 drivers/net/ethernet/intel/igb/e1000_82575.c      |   6 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   3 +-
 25 files changed, 1003 insertions(+), 738 deletions(-)

-- 
1.8.3.1
