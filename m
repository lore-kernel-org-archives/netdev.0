From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2017-10-09
Date: Mon,  9 Oct 2017 15:38:27 -0700
Message-ID: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36088 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754068AbdJIWjE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jake fixes missed flag conversion from u64 to u32.  Fixes a deafult ITR
value issue where the driver defaults to an ITR value of half the
expected value (in terms of minimum microseconds between interrupts).  So
fix this by changing the default values to be calculated using the
ITR_REG_TO_USEC() macro which indicates that we are converting from the
register units into microseconds. Updates the drivers to bump the tail in
increments of 8 and double the number of descriptors we will bundle into
one tail bump when receiving.  With the recent kernel support for
enabling XPS and QoS at the same time, we no longer need to worry about
the number of traffic classes when enabling XPS.

Lihong converts the use of hash_for_each() to hash_for_each_safe() to
safely remove a hash entry.  Adds a check for the return value for
find_first_bit() in the case that it returns the size passed to search.

Alan fixes a bug in which filters are erroneously removed if they are
removed and then added again.  So make sure that when adding a filter, if
we find it already existed in our list, make sure it is not marked to be
removed.

Jayaprakash adds the retrying of PHY reads when the I2C is busy for a
maximum period of 500ms.

Rami fixes code comment typo.

Stefano Brivio simplifies the code by removing the use of a local
return code variable and simply return the results of the read function.

The following are changes since commit 2e997d8b12d2933d7640bb3a43af8eb6857a73af:
  Merge branch 'ipv6-addrlabel-avoid-dirtying-ip6addrlbl_entry'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40evf: fix mac filter removal timing issue

Jacob Keller (7):
  i40e: fix flags declaration
  i40e/i40evf: fix incorrect default ITR values on driver load
  i40e/i40evf: always set the CLEARPBA flag when re-enabling interrupts
  i40e: reduce lrxqthresh from 2 to 1
  i40e/i40evf: bump tail only in multiples of 8
  i40e/i40evf: bundle more descriptors when allocating buffers
  i40e: allow XPS with QoS enabled

Jayaprakash Shanmugam (1):
  i40e: Retry AQC GetPhyAbilities to overcome I2CRead hangs

Lihong Yang (3):
  i40e: use the safe hash table iterator when deleting mac filters
  i40e: add check for return from find_first_bit call
  i40e: use a local variable instead of calculating multiple times

Rami Rosen (1):
  i40e: fix a typo

Stefano Brivio (1):
  i40e: Avoid some useless variables and initializers in NVM functions

 drivers/net/ethernet/intel/i40e/i40e.h             |  7 ++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 42 +++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 36 ++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 20 ++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 15 +++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  8 +++--
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 27 +++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 13 +++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  8 +++--
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  3 ++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  6 ++--
 12 files changed, 107 insertions(+), 81 deletions(-)

-- 
2.14.2
