From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/3][pull request] 40GbE Intel Wired LAN Driver Updates 2016-10-03
Date: Mon,  3 Oct 2016 19:25:00 -0700
Message-ID: <1475547903-22168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52990 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751662AbcJDCZF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 22:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to i40e only.

Stefan Assmann provides the changes in this series to resolve an issue
where when we run out of MSIx vectors, iWARP gets disabled automatically.
First adds a check for "no vectors left" during MSIx vector allocation
for VMDq, which will prevent more vectors being allocated than available.
Then fixed the MSIx vector redistribution when we reach the hardware limit
for vectors so that additional features like VMDq, iWARP, etc do not get
starved for vectors because the PF is hogging all the resources.  Lastly,
fix the issue for flow director by moving the check for the reaching the
vector limit earlier in the code so that a decision can be made on
disabling flow director.

The following are changes since commit b9118b7221ebb12156d2b08d4d5647bc6076d6bb:
  ptp: Fix resource leak in case of error
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Stefan Assmann (3):
  i40e: check if vectors are already depleted when doing VMDq allocation
  i40e: fix MSI-X vector redistribution if hw limit is reached
  i40e: fix sideband flow director vector allocation

 drivers/net/ethernet/intel/i40e/i40e_main.c | 76 ++++++++++++++++++-----------
 1 file changed, 47 insertions(+), 29 deletions(-)

-- 
2.7.4
