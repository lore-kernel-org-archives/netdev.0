From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates 2015-12-03
Date: Thu,  3 Dec 2015 13:57:50 -0800
Message-ID: <1449179874-49174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60729 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731AbbLCV5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 16:57:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, i40e/i40evf, MAINTAINERS and e100.txt

Alex provides a fix for ixgbe where enabling SR-IOV and then bringing the
interface up was resulting in the PF MAC addresses getting into a bad state.
The workaround for this issue is to bring up the interface first and then
enable SR-IOV as this will trigger the reset in the existing code.

I clean up legacy license stuff in the e100.txt documentation and then
update the maintainers/reviewers list for our drivers.

Jesse fixes an issue with the i40e/i40evf drivers, where if the driver were
to happen to have a mutex held while the i40e_init_adminq() call was called,
the init_adminq might inadvertently call mutex_init on a lock that was held
which is a violation of the calling semantices.

The following are changes since commit cf18b7788fe1bf99e9c2ab580b065bf2d3cb1a34:
  net: phy: reset only targeted phy
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Alexander Duyck (1):
  ixgbe: Reset interface after enabling SR-IOV

Jeff Kirsher (2):
  e100.txt: Cleanup license info in kernel doc
  MAINTAINERS: Update Intel Wired LAN reviewers

Jesse Brandeburg (1):
  i40e/i40evf: avoid mutex re-init

 Documentation/networking/e100.txt               | 14 --------------
 MAINTAINERS                                     |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  6 ------
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 11 ++++++++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |  6 ------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 ++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  3 +++
 7 files changed, 24 insertions(+), 28 deletions(-)

-- 
2.5.0
