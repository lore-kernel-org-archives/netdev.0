From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-05-01
Date: Sun,  1 May 2016 17:06:06 -0700
Message-ID: <1462147581-135254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35057 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbcEBAGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 20:06:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

The theme of this series is code reduction, with several code cleanups in
this series.  Starting with Neerav's removal of the code that implemented
the HMC AQ APIs and calls, since they are now obsolete and not supported
by firmware.

Anjali changes the default of VFs to make sure they are not trusted or
privileged until its explicitly set for trust through the new NDO op
interface.  Also limited the number of MAC and VLAN addresses a VF can
add if it is untrusted/privileged.

Carolyn syncs the VF code for the changes made to the PF for the RSS
hash tuple settings, which ends up cleaning up much of the existing code.

Jesse cleans up compiler warnings which were found with gcc's W=2 option.
Then removed duplicate code, especially since only one copy was actually
being used.

Jacob addresses an issue which was found when testing GCC 6's which
happens to produce new warnings when you left shift a signed value
beyond the storage sizeof the type.  The converts i40e & i40evf to use
the BIT() macro more consistently.

Alex actually bucks the trend of code removal by adding support for
both drivers to use GSO_PARTIAL so that segmentation of frames with
checksums enabled in outer headers is supported.  Fortunately it does
not take much to add this support!

The following are changes since commit 3cfef195212976032ce7bcd6b4d0b9f1e4741725:
  Merge branch 'mlx5-aRFS'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (1):
  i40e/i40evf: Add support for GSO partial with UDP_TUNNEL_CSUM and
    GRE_CSUM

Anjali Singhai Jain (3):
  i40e: Change the default for VFs to be not privileged
  i40e: Limit the number of MAC and VLAN addresses that can be added for
    VFs
  i40e: Prevent falling to promiscuous if the VF is not trusted

Carolyn Wyborny (1):
  i40evf: RSS Hash Option parameters

Catherine Sullivan (2):
  i40e: Fix uninitialized variable
  i40e: Update device ids for X722

Harshitha Ramamurthy (1):
  i40e/i40evf : Bump driver version from 1.5.5 to 1.5.10

Jacob Keller (3):
  i40e/i40evf: fix I40E_MASK signed shift overflow warnings
  i40e: make use of BIT() macro to prevent left shift of signed values
  i40evf: make use of BIT() macro to avoid signed left shift

Jesse Brandeburg (3):
  i40e: PTP - avoid aggregate return warnings
  i40e: Use consistent type for vf_id
  i40e: Drop extra copy of function

Neerav Parikh (1):
  i40e: Remove HMC AQ API implementation

 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   4 -
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  78 +++-----
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  30 ---
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  37 ++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   4 -
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   7 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  64 ++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   7 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  69 +++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   7 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 201 +--------------------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  12 +-
 16 files changed, 137 insertions(+), 392 deletions(-)

-- 
2.5.5
