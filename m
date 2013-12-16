From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/12][pull request] Intel Wired LAN Driver Updates
Date: Mon, 16 Dec 2013 01:38:46 -0800
Message-ID: <1387186738-13666-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10462 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948Ab3LPJjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:39:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only (again).

Jesse provides a fix for when tx_rings structure is NULL and we do not want
to panic. Then refactors the flow control set up and disables L2 flow control
by default.  Provides some trivial fixes as well as prevent compiler warnings.
Then to align to similar behaviour in ixgbe, use the total number of CPUs in
the system to suggest the number of transmit and receive queue pairs.
  
Shannon provides a i40e ethtool fix to get some more reasonable information
reports back out to the ethtool.  In addition, fixes PF reset after offline
test, where it reorders the test to put the register test last as it is the
only one that needs a reset, and we wait to trigger the reset until after we
clear the testing bit.  Lastly provides basic support for handling suspend
and resume for now, later on Wake-On-LAN support will be added.

Anjali provides changes to tell the stack about our actual number of queues
in order for RFS/RPS/XFS to work correctly.  Then provides several patches to
implement dynamically changing the queue count for the main VSI.  Adds
basic support for get/set channels for RSS so that the number of receive and
transmit queue pair can be changed via ethtool.  Cleans up the use of
rtnl_lock in the reset patch since it runs from a work time.

Neerav Parikh cleans up the VF interface to remove FCoE code as this
feature will not be supported on VF interfaces.

v2:
  - submitted patch 1 to net (since it was a fix needed for net), so dropped
    from this series (this patch will get added to net-next when Dave syncs
    his trees)
  - Dropped patches 4 & 11 from previous submission because of feedback
    received from Ben Hutchings and Sergei Shtylyov.

The following are changes since commit 810c23a3553cbb4602edf9534b548d2616ba5520:
  net-ipv6: Fix alleged compiler warning in ipv6_exthdrs_len()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (5):
  i40e: Tell the stack about our actual number of queues
  i40e: reinit flow for the main VSI
  i40e: function to reconfigure RSS queues and rebuild
  i40e: Add basic support for get/set channels for RSS
  i40e: rtnl_lock in reset path fixes

Jesse Brandeburg (4):
  i40e: fix up some of the ethtool connection reporting
  i40e: init flow control settings to disabled
  i40e: trivial fixes
  i40e: use same number of queues as CPUs

Neerav Parikh (1):
  i40e: Remove FCoE in i40e_virtchnl_pf.c code

Shannon Nelson (2):
  i40e: fix pf reset after offline test
  i40e: support for suspend and resume

 drivers/net/ethernet/intel/i40e/i40e.h             |   4 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 146 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 364 ++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   4 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  29 +-
 8 files changed, 469 insertions(+), 90 deletions(-)

-- 
1.8.3.1
