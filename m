From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates 2015-03-09
Date: Mon,  9 Mar 2015 10:55:33 -0700
Message-ID: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5904 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752192AbbCIRzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Greg cleans up some "hello world" strings which were left around from
early development.

Shannon modifies the drive to make sure the sizeof() calls are taking
the size of the actual struct that we care about.  Also updates the
NVMUpdate read/write so that it is less noisy when logging.  This was
because the NVMUpdate tool does not necessarily know the ReadOnly map of
the current NVM image, and must try reading and writing words that may be
protected.  This generates an error out of the Firmware request that the
driver logs.  Unfortunately, this ended up spitting out hundreds of
bogus read/write error messages.  If a user wants the noisy logging,
the change can be overridden by enabling the NVM update debugging.

Mitch fixes a possible deadlock issue where if a reset occurred when the
netdev is closed, the reset task will hang in napi_disable.  Added
ethtool RSS support as suggested by Ben Hutchings.

Jesse fixes a bug introduced in the force writeback code, where the
interrupt rate was set to 0 (maximum) by accident.  The driver must
correctly set the NOITR fields to avoid IT update as a side effect
of triggering the software interrupt.

I provided a simple cleanup to make the use of PF/VF consistent, which
was reported by Joe Perches.

The following are changes since commit fc6c6c2b8a2e1fbaa9e864af62c873dae15420ea:
  net/macb: Update DT bindings documentation
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e/i40evf version

Greg Rose (1):
  i40e: Remove "hello world" strings from i40e driver

Jeff Kirsher (1):
  i40e: Fix inconsistent use of PF/VF vs pf/vf

Jesse Brandeburg (1):
  i40e/i40evf: fix accidental write to ITR registers

Mitch A Williams (1):
  i40e: add ethtool RSS support

Mitch Williams (1):
  i40vf: don't stop me now

Shannon Nelson (3):
  i40e: future proof some sizeof calls
  i40e: tame the nvmupdate read and write complaints
  i40e: add MAC printing to debugfs dump VSI

 drivers/net/ethernet/intel/i40e/i40e.h             |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  29 +--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 117 ++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  60 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 222 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  12 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  16 +-
 12 files changed, 313 insertions(+), 187 deletions(-)

-- 
1.9.3
