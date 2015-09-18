From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates 2015-09-17
Date: Thu, 17 Sep 2015 17:17:52 -0700
Message-ID: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18405 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbbIRASF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Shannon provides updates to i40e and i40evf to resolve an issue with the
nvmupdate utility.  First renames a variable name to reduce confusion and
to differentiate it from the actual user variable.  Then added the ability
to save the admin queue write back descriptor if a caller supplies a
buffer for it to be saved into.  Added a new GetStatus command so that
the NVM update tool can query the current status instead of doing fake
write requests to probe for readiness.  Added wait states to the NVM
update state machine to signify when waiting for an update operation to
finish, whether we are in the middle of a set of write operations, or we
are now idle but waiting.  Then added a facility to run admin queue
commands through the NVM update utility in order to allow the update
tools to interact with the firmware and do special commands needed for
updates and configuration changes.  Also added a facility to recover the
result of a previously run admin queue command.

---
Waiting for Dave to update his net-next tree before pushing this series
to my next-queue tree.

The following are changes since commit 9adbac599a71bc25a2617850ffcaa4388dc5c20d:
  fm10k: fix iov_msg_mac_vlan_pf VID checks
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 1.3.21 and i40evf to 1.3.13

Shannon Nelson (7):
  i40e: rename variable to prevent clash of understanding
  i40e/i40evf: save aq writeback for future inspection
  i40e/i40evf: add handling of writeback descriptor
  i40e/i40evf: add GetStatus command for nvmupdate
  i40e/i40evf: add wait states to NVM state machine
  i40e/i40evf: add exec_aq command to nvmupdate utility
  i40e/i40evf: add get AQ result command to nvmupdate utility

 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  20 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c     |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      | 386 +++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_type.h     |  10 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |   7 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |  10 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   2 +-
 9 files changed, 354 insertions(+), 85 deletions(-)

-- 
2.4.3
