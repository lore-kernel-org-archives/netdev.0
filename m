From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-08-18
Date: Thu, 18 Aug 2016 14:57:21 -0700
Message-ID: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:27358 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754454AbcHSBBV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:01:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Wei Yongjun updates i40e to use list_move() instead of list_del() &
list_add() operations.

Anjali fixes an issue where the client->open call was not protected with
the client instance mutex, which allowed client->close to be called before
the open all completed.

Catherine makes sure that the VLAN count (and stats) gets reset to 0
after reset.

Jake provides two patches, first adds the needed rtnl lock around
i40evf_set_interrupt_capability() since i40evf_init_task() does not
hold the rtnl_lock.  Second fixes an issue where users could reduce
the number of channels (queues) below the current flow director
filter rules targets.

Dave fixes a problem where a static analysis tool generates a warning
so eliminating the irrelevant check and redundant assignment for the
value of enabled_tc.

Avinash fixes an sync issue where the iWARP device open is called
before the PCI register writes are completed, so ensure the register
writes complete before exiting the setup function.

Alan fixes a bug which causes RSS to continue to work after being
disabled.

Carolyn implements a feature change which allows using ethtool to set
RDD hash options using less than four parameters if desired.

Dan Carpenter cleans up a stray unlock.

Sridhar exposes the "trust" flag to userspace via ndo_get_vf_config().

The following are changes since commit 60747ef4d173c2747bf7f0377fb22846cb422195:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40e: fix lookup table when RSS disabled/enabled

Anjali Singhai Jain (1):
  i40e: Fix a bug where a client close can be called before an open is
    complete

Avinash Dayanand (2):
  i40e: Force register writes to mitigate sync issues with iwarp VF
    driver
  i40e: Don't notify client of VF reset during VF creation

Bimmy Pujari (1):
  i40e/i40evf-Bump version from 1.6.11 to 1.6.12

Carolyn Wyborny (1):
  i40e: Allow RSS Hash set with less than four parameters

Catherine Sullivan (2):
  i40e/i40evf: Reset VLAN filter count when resetting
  i40e: reset RX csum error stat with other pf stats

Dan Carpenter (1):
  i40e: remove a stray unlock

Dave Ertman (1):
  i40e: Fix static analysis tool warning

Jacob Keller (2):
  i40evf: add missing rtnl_lock() around i40evf_set_interrupt_capability
  i40e: don't allow reduction of channels below active FD rules

Mitch Williams (1):
  i40e: fix memory leak

Sridhar Samudrala (1):
  i40e: Expose 'trust' flag to userspace via ndo_get_vf_config.

Wei Yongjun (1):
  i40e: Use list_move instead of list_del/list_add

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 -
 drivers/net/ethernet/intel/i40e/i40e_client.c      |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 232 ++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  35 +++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  10 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   4 +-
 6 files changed, 201 insertions(+), 92 deletions(-)

-- 
2.7.4
