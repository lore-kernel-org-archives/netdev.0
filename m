From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/10][pull request] 40GbE Intel Wired LAN Driver Updates 2017-03-27
Date: Mon, 27 Mar 2017 16:52:00 -0700
Message-ID: <20170327235210.28652-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27157 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752575AbdC0XwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 19:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Alex updates the driver code so that we can do bulk updates of the page
reference count instead of just incrementing it by one reference at a
time.  Fixed an issue where we were not resetting skb back to NULL when
we have freed it.  Cleaned up the i40e_process_skb_fields() to align with
other Intel drivers.  Removed FCoE code, since it is not supported in any
of the Fortville/Fortpark hardware, so there is not much point of carrying
the code around, especially if it is broken and untested.

Harshitha fixes a bug in the driver where the calculation of the RSS size
was not taking into account the number of traffic classes enabled.

Robert fixes a potential race condition during VF reset by eliminating
IOMMU DMAR Faults caused by VF hardware and when the OS initiates a VF
reset and before the reset is finished we modify the VF's settings.

Bimmy removes a delay that is no longer needed, since it was only needed
for preproduction hardware.

Colin King fixes null pointer dereference, where VSI was being
dereferenced before the VSI NULL check.

Jake fixes an issue with the recent addition of the "client code" to the
driver, where we attempt to use an uninitialized variable, so correctly
initialize the params variable by calling i40e_client_get_params().

v2: dropped patch 5 of the original series from Carolyn since we need
    more documentation and reason why the added delay, so Carolyn is
    taking the time to update the patch before we re-submit it for
    kernel inclusion.

The following are changes since commit 402a5bc462d47f0b7c9e8a516c124c9c162fe2aa:
  ipv6: sr: select DST_CACHE by default
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (5):
  i40e/i40evf: Update code to better handle incrementing page count
  i40e/i40evf: Fix use after free in Rx cleanup path
  i40e/i40evf: Clean-up process_skb_fields
  i40e: Drop FCoE code from core driver files
  i40e: Drop FCoE code that always evaluates to false or 0

Bimmy Pujari (1):
  i40e: removed no longer needed delays

Colin Ian King (1):
  i40evf: dereference VSI after VSI has been null checked

Harshitha Ramamurthy (1):
  i40e: fix configuration of RSS table with DCB

Jacob Keller (1):
  i40e: initialize params before notifying of l2_param_changes

Robert Konklewski (1):
  i40e: Fixed race conditions in VF reset

 drivers/net/ethernet/intel/Kconfig                 |  11 -
 drivers/net/ethernet/intel/i40e/Makefile           |   1 -
 drivers/net/ethernet/intel/i40e/i40e.h             |  62 -----
 drivers/net/ethernet/intel/i40e/i40e_client.c      |   2 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  27 --
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  19 --
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  35 ---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 295 +--------------------
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |   3 -
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   3 -
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  60 ++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  24 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 138 ----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  43 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   1 -
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  33 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  19 +-
 drivers/net/ethernet/intel/i40evf/i40evf_client.c  |   9 +-
 18 files changed, 112 insertions(+), 673 deletions(-)

-- 
2.12.0
