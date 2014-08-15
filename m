From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates 2014-08-15
Date: Fri, 15 Aug 2014 04:37:50 -0700
Message-ID: <1408102673-27206-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39386 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaHOLi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 07:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to i40e only.

Anjali provides two fixes for i40e, first adds a check for non-active
VF before sending admin queue messages to the VFS.  This resolves a
potential kernel panic which would happen whenever we got a Tx hang and
there were VFS that were not up or enabled.  The second fix adds
additional checks so that we do try to access a VF that is not up or
enabled which would dereference a null pointer.

Jesse fixes a i40e PTP bug where the hang detection routine was never
being run when PTP was enabled.

The following are changes since commit c9d26423e56ce1ab4d786f92aebecf859d419293:
  Merge tag 'pm+acpi-3.17-rc1-2' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Anjali Singhai Jain (2):
  i40e: Fix for recent kernel panic
  i40e: Fix a few potential VF dereferences

Jesse Brandeburg (1):
  i40e: fix PTP bug

 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 44 ++++++++++++++++------
 2 files changed, 33 insertions(+), 13 deletions(-)

-- 
1.9.3
