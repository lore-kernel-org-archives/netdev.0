From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2017-09-05
Date: Tue,  5 Sep 2017 18:04:16 -0700
Message-ID: <20170906010418.39007-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63879 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753787AbdIFBEY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 21:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes for i40e only.

These two patches fix an issue where our nvmupdate tool does not work on RHEL 7.4
and newer kernels, in fact, the use of the nvmupdate tool on newer kernels can
cause the cards to be non-functional unless these patches are applied.

Anjali reworks the locking around accessing the NVM so that NVM acquire timeouts
do not occur which was causing the failed firmware updates.

Jake correctly updates the wb_desc when reading the NVM through the AdminQ.

The following are changes since commit 6d9c153a0b84392406bc77600aa7d3ea365de041:
  net: dsa: loop: Do not unregister invalid fixed PHY
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue 40GbE

Anjali Singhai Jain (1):
  i40e: avoid NVM acquire deadlock during NVM update

Jacob Keller (1):
  i40e: point wb_desc at the nvm_wb_desc during i40e_read_nvm_aq

 drivers/net/ethernet/intel/i40e/i40e_nvm.c       | 99 +++++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 -
 2 files changed, 61 insertions(+), 40 deletions(-)

-- 
2.14.1
