From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 00/15] Intel Wired LAN Driver Updates
Date: Thu, 13 Feb 2014 03:48:38 -0800
Message-ID: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56830 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156AbaBMLvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf, primarily reset
handling / refactoring along with a fair amount of minor cleanup.

Jesse fixes some spelling, bumps the version and other trivial fixes.
Akeem sets a bit that is needed before shutdown in the case of 
tx_timeout recovery failure.  Mitch refactors reset handling along 
with a whole bunch of clean up.

Jesse Brandeburg (3):
  i40e: spelling error
  i40e: bump driver version
  i40evf: trivial fixes

Akeem G Abodunrin (1):
  i40e: Setting i40e_down bit for tx_timeout

Mitch Williams (11):
  i40evf: clean up memsets
  i40e: remove dead code
  i40e: set VF state to active when reset is complete
  i40e: reset VFs after PF reset
  i40e: enable extant VFs
  i40e: don't handle VF reset on unload
  i40evf: clean up adapter struct
  i40evf: fix bogus comment
  i40evf: don't store unnecessary array of strings
  i40evf: change type of flags variable
  i40evf: refactor reset handling

 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  28 +++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  32 ++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   4 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  42 ++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 155 ++++++++++++++++-----
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  15 +-
 10 files changed, 183 insertions(+), 109 deletions(-)

-- 
1.8.5.GIT
