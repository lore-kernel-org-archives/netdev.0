From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 10GbE Intel Wired LAN Driver Updates 2016-05-04
Date: Wed,  4 May 2016 09:26:34 -0700
Message-ID: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38611 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbcEDQ1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:27:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf and traffic class helpers.

Sridhar adds helper functions to the tc_mirred header to access tcf_mirred
information and then implements them for ixgbe to enable redirection to
a SRIOV VF or an offloaded MACVLAN device queue via tc 'mirred' action.

Amritha adds support to set filters with multiple header fields (L3,L4)
to match on.

KY Srinivasan from Microsoft add Hyper-V support into ixgbevf.

Emil adds 82599 sub-device IDs that were missing from the list of parts
that support WoL.  Then simplified the logic we use to determine WoL
support by reading the EEPROM bits for MACs X540 and newer.

Preethi cleaned up duplicate and unused device IDs.  Fixed our ethtool
stat reporting where we were ignoring higher 32 bits of stats registers,
so fill out 64 bit stat values into two 32 bit words.

Babu Moger from Oracle improves VF performance issues on SPARC.

Alex Duyck cleans up some of the Hyper-V implementation from KY so that
we can just use function pointers instead of having to identify if a
given VF is running on a Linux or Windows PF.

Usha makes sure that DCB and FCoE is disabled for X550EM_x/a MACs and
cleans up the DCB initialization in the process.

Tony cleans up the API for ixgbevf_update_xcast_mode() so we do not
have to pass in the netdev parameter, since it was never used in the
function. 

The following are changes since commit 26879da58711aa604a1b866cbeedd7e0f78f90ad:
  ipv6: add new struct ipcm6_cookie
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (1):
  ixgbevf: Use mac_ops instead of trying to identify NIC type

Amritha Nambiar (1):
  ixgbe: Match on multiple headers for cls_u32 offloads

Babu Moger (1):
  ixgbevf: Change the relaxed order settings in VF driver for sparc

Emil Tantilov (2):
  ixgbe: add WoL support for some 82599 subdevice IDs
  ixgbe: check EEPROM for WOL support for X540 and above

KY Srinivasan (2):
  ixgbevf: Add the device ID's presented while running on Hyper-V
  ixgbevf: Support Windows hosts (Hyper-V)

Preethi Banala (3):
  ixgbe: Remove duplicate and unused device ID definitions
  ixgbe: Return 64 bit stats values
  ixgbe: Revise populating few registers and macro definitions

Sridhar Samudrala (2):
  net_sched: act_mirred: add helper inlines to access tcf_mirred info
  ixgbe: Add support for redirect action to cls_u32 offloads

Tony Nguyen (1):
  ixgbevf: Remove unused parameter

Usha Ketineni (1):
  ixgbe: Disable DCB and FCoE for X550EM_x and x550em_a

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |  27 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 480 +++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h    |   6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  25 +-
 drivers/net/ethernet/intel/ixgbevf/defines.h      |   5 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  10 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  28 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |  11 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 219 +++++++++-
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   4 +-
 include/net/tc_act/tc_mirred.h                    |  15 +
 12 files changed, 640 insertions(+), 197 deletions(-)

-- 
2.5.5
