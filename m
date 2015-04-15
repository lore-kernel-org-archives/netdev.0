From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2015-04-14
Date: Tue, 14 Apr 2015 21:51:37 -0700
Message-ID: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbbDOEvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:51:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Mitch provides a fix for i40e, where VFs were gone and the associated
VSI's had been removed and the rings were not stopped, which in some
circumstances cased memory corruption or DMAR errors.  So stop all the
rings associated with each VF before releasing its resources.  Also
cleaned up a poorly indented piece of code.  Fixes VF link state, where
VF devices were assuming link is up unless told otherwise, which means
that VFs instantiated on a PF with no link, would report the wrong state.

Anjali adds support to add Flow director Sideband rules for a VF from it's
PF.  Fixes a recently discovered hardware issue, where after a VFLR
hardware might be indicating to us a reset completion little too early, so
wait another 10 msec for cache to be cleaned up.

Jesse enables the user to dump the internal hardware state for better
debugging by allowing a bash script to acquire information about the
internal hardware state.  The data output to the kernel log is collected
by the script and can then be sent to Intel.  Also fixed a possible
failure path to allocate memory that was found by smatch.  Cleaned up
unused local variables.

The following are changes since commit f4f88c6d3b6fe1632ddb567be155698733e857a1:
  fm10k: Bump driver version to 0.15.2
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (2):
  i40e: Add support to program FDir SB rules for VF from PF through
    ethtool
  i40e: For VF reset (VFR and VFLR) add some more delay

Catherine Sullivan (1):
  i40e: Bump version to 1.3.2

Greg Rose (1):
  i40e: Use new 40G speeds

Jesse Brandeburg (3):
  i40e: enable user dump of internal hardware state
  i40e: handle possible memory allocation failure
  i40e: get rid of unused locals

Kevin Scott (1):
  i40e/i40evf: Save WR_CSR_PROT field from DEV/FUNC capabilities

Mitch Williams (5):
  i40e: stop VF rings
  i40evf: fix bad indentation
  i40evf: remove aq_pending
  i40e: notify VFs of link state
  i40e: move VF notification routines up

Vasu Dev (1):
  i40e: print FCoE capability reported by the device function

 drivers/net/ethernet/intel/i40e/i40e_common.c      |  65 ++++++
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  45 ++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  29 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   5 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 244 +++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   9 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  42 +---
 13 files changed, 304 insertions(+), 163 deletions(-)

-- 
1.9.3
