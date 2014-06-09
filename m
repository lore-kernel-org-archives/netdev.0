From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates 2014-06-09
Date: Mon,  9 Jun 2014 01:49:05 -0700
Message-ID: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27476 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808AbaFIItW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains more updates to i40e and i40evf.

Shannon adds checks for error status bits on the admin event queue and
provides notification if seen.  Cleans up unused variable and memory
allocation which was used earlier in driver development and is no longer
needed.  Also fixes the driver to not complain about removing
non-existent MAC addresses.  Bumps the driver versions for both i40e
and i40evf.

Catherine fixes a function header comment to make sure the comment correctly
reflects the function name.

Mitch adds code to allow for additional VSIs since the number of VSIs that
the firmware reports to us is a guaranteed minimum, not an absolute
maximum.  The hardware actually supports for more than the reported value,
which we often need.  Implements anti-spoofing for VFs for both MAC
addresses and VLANs, as well as enable this feature by default for all VFs.

Anjali changes the interrupt distribution policy to change the way
resources for special features are handled.  Fixes the driver to not fall
back to one queue if the only feature enabled is ATR, since FD_SB
and FD_ATR need to be checked independently in order to decide if we
will support multiple queue or not.  Allows the RSS table entry range
and GPS to be any number, not necessarily a power of 2 because hardware
does not restrict us to use a power of 2 GPS in the case of RSS as long as
we are not sharing the RSS table with another VSI (VMDq).

Frank modifies the driver to keep SR-IOV enabled in the case that RSS,
VMFq, FD_SB and DCB are disabled so that SR-IOV does not get turned off
unnecessarily.

Jesse fixes a bug in receive checksum where the driver was not marking
packets with bad checksums correctly, especially IPv6 packets with a bad
checksum.  To do this correctly, we need a define that may be set by
hardware in rare cases.

Greg fixes the driver to delete all the old and stale MAC filters for the
VF VSI when the host administrator changes the VF MAC address from under
its feet.

The following are changes since commit b78370c021c9d52721c7f96fbb3e10f5b2f428d3:
  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (3):
  i40e: Changes to Interrupt distribution policy
  i40e: Do not fall back to one queue model if the only feature enabled
    is ATR
  i40e: Allow RSS table entry range and GPS to be any number, not
    necessarily power of 2

Catherine Sullivan (1):
  i40evf: Fix function header

Frank Zhang (1):
  i40e: keep SR-IOV enabled in the case that RSS, VMDQ, FD_SB and DCB
    are disabled

Greg Rose (1):
  i40e: Delete stale MAC filters after change

Jesse Brandeburg (1):
  i40e/i40evf: add PPRS bit to error bits and fix bug in Rx checksum

Mitch Williams (2):
  i40e: allow for more VSIs
  i40e: implement anti-spoofing for VFs

Shannon Nelson (4):
  i40e: add checks for AQ error status bits
  i40e: remove unused variable and memory allocation
  i40e: don't complain about removing non-existent addresses
  i40e/i40evf: bump version to 0.4.7 for i40e and 0.9.31 for i40evf

 drivers/net/ethernet/intel/i40e/i40e.h             |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 177 ++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  76 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  65 ++++++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  74 ++++++---
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   4 +-
 12 files changed, 303 insertions(+), 113 deletions(-)

-- 
1.9.3
