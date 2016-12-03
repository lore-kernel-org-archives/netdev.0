From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] 40GbE Intel Wired LAN Driver Updates 2016-12-02
Date: Sat,  3 Dec 2016 01:19:12 -0800
Message-ID: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28618 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750787AbcLCJU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Alex provides changes so that we are much more robust about defining what
we can and cannot offload in i40e and i40evf by doing additional checks
other than L4 tunnel header length.

Jake provides several fixes/changes, first cleaning up a label that is
unnecessary, as well as cleaned up the use of a "magic number".  Clarified
the code by separating the global private flags and the regular private
flags per interface into two arrays, so that future additions will not
produce duplication and buggy code.  Adds additional checks to protect
against NULL values for msix_entries and q_vectors pointers.

Michal adds Clause22 method for accessing registers for some external
PHYs.

Piotr adds additional protocol support for the admin queue discover
capabilities function.

Tushar Dave fixes a panic seen on SPARC, where writel() should not be
used to write directly to a memory address but only to a memory mapped
I/O address otherwise it causes data access exceptions.

Joe Perches separates out a section of code into its own function, to
help reduce i40evf_reset_task() a bit.

Alan fixes an issue by checking for NULL before dereferencing msix_entries
and returning early in the case where it is NULL within the i40evf_close()
code path.

Henry provides code cleanup to remove unreachable and redundant sections
of code.  Fixed up an issue where new NICs were not identifying "unknown
PHYs" correctly.

Harshitha fixes a issue where the ethtool "Supported Link" modes list
backplane interfaces on X722 devices for 10 GbE with SFP+ and Cortina
retimer, where these interfaces should not be visible to the user since
they cannot use them.

Carolyn changes an X722 informational message so that it only appears
when extra messages are desired.

The following are changes since commit ab17cb1fea82b346bdecd4f2d7f0e84e80f847af:
  Merge tag 'wireless-drivers-next-for-davem-2016-12-01' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40evf: check for msix_entries null dereference

Alexander Duyck (2):
  i40e: Be much more verbose about what we can and cannot offload
  i40evf: Be much more verbose about what we can and cannot offload

Carolyn Wyborny (1):
  i40e: change message to only appear when extra debug info is wanted

Harshitha Ramamurthy (1):
  i40e: Fix for ethtool Supported link modes

Henry Tieman (2):
  i40e: Remove unreachable code
  i40e: Pass unknown PHY type for unknown PHYs

Jacob Keller (7):
  i40e: remove error_param_int label from
    i40e_vc_config_promiscuous_mode_msg
  i40e: remove second check of VLAN_N_VID in i40e_vlan_rx_add_vid
  i40e: avoid duplicate private flags definitions
  i40e: fix trivial typo in naming of i40e_sync_filters_subtask
  i40evf: protect against NULL msix_entries and q_vectors pointers
  i40e: set broadcast promiscuous mode for each active VLAN
  i40e/i40evf: replace for memcpy with single memcpy call in ethtool

Joe Perches (1):
  i40evf: Move some i40evf_reset_task code to separate function

Michal Kosiarz (1):
  i40e: Add Clause22 implementation

Piotr Raczynski (1):
  i40e: Add protocols over MCTP to i40e_aq_discover_capabilities

Tushar Dave (1):
  i40e: fix panic on SPARC while changing num of desc

 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 218 ++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  78 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 171 ++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  23 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  14 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   4 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 171 +++++++++++-----
 9 files changed, 511 insertions(+), 184 deletions(-)

-- 
2.9.3
