From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates 2014-10-23
Date: Thu, 23 Oct 2014 21:09:57 -0700
Message-ID: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57054 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437AbaJXEKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Jesse modifies the i40e driver to only notify the firmware on link up/down
and qualified module events.  Also simplified the job of managing link
state by using the admin queue receive event for link events as a signal
to tell the driver to update link state.

Jeff (me) cleans up the inconsistent use of tabs for indentation in the admin
queue command header file.

Neerav converts the use of udelay() to usleep_range().

Anjali fixes a bug where receive would stop after some stress by adding
a sleep and restart as well as moving the setting of flow control because
it should be done at a PF level and not a VSI level.

Mitch adds code to handle link events when updating the PF switch, which
allows link information to be properly provided to VFS in all cases.

Catherine adds driver support for 10GBaseT and bumps driver version.

The following are changes since commit 61ed53deb1c6a4386d8710dbbfcee8779c381931:
  Merge tag 'ntb-3.18' of git://github.com/jonmason/ntb
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (1):
  i40e: Moving variable declaration out of the loops

Anjali Singhai Jain (1):
  i40e: Fix a bug where Rx would stop after some time

Catherine Sullivan (1):
  i40e: Bump version

Jeff Kirsher (1):
  i40e/i40evf: Fix whitespace indentation

Jesse Brandeburg (2):
  i40e: mask phy events
  i40e: enable LSE poke and simplify link state

Mitch Williams (2):
  i40e: process link events when setting up switch
  i40e: Add 10GBaseT support

Neerav Parikh (1):
  i40e/i40evf: Use usleep_range() instead of udelay()

 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 2139 ++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   28 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   33 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  108 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |    2 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |    1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |    2 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 2136 ++++++++++---------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |    4 +-
 9 files changed, 2268 insertions(+), 2185 deletions(-)

-- 
1.9.3
