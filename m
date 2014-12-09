From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/13][pull request] Intel Wired LAN Driver Updates 2014-12-09
Date: Tue,  9 Dec 2014 13:26:07 -0800
Message-ID: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29734 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397AbaLIV0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Jeff (me) provides a single patch to convert a macro to a static inline
function based on feedback from Joe Perches on a previous patch.

Shannon provides the remaining twelve patches against i40e.  Almost all
of Shannon's patches cleanup/fix NVM issues varying in range from
adding more detail to debug messages, to removing dead code, to fixing
NVM state transitions after an error.  Change the handy decoder interface
for admin queue return code to help catch and properly report the condition
as a useful errno rather than returning a misleading '0'.  Added a range
check to avoid any possible array index-out-of-bound issues.

v2:
 - fixed up patch 05 in the series to use the ARRAY_SIZE() macro as suggested
   by Sergei Shtylyov
 - fix up patch 13 to remove unnecessary parens in the return statement
   as suggested by Sergei Shtylyov

The following are changes since commit b2abeeddad3844072d63f27602b581d9c4adc134:
  net: ethernet: rocker: Add dependency to CONFIG_BRIDGE in Kconfig
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Jeff Kirsher (1):
  i40e/i40evf: Convert macro to static inline

Shannon Nelson (12):
  i40e: clear NVM update state on ethtool test
  i40e: better error messages for NVM update issues
  i40e: let firmware catch the NVM busy error
  i40e: rework debug messages for NVM update
  i40e: add range check to i40e_aq_rc_to_posix
  i40e: init NVM update state on adminq init
  i40e: remove unused nvm_semaphore_wait
  i40e: set max limit for access polling
  i40e: fix up NVM update sm error handling
  i40e: poll on NVM semaphore only if not other error
  i40e: check for AQ timeout in aq_rc decode
  i40e: add to NVM update debug message

 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  13 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c  |  55 ++++---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      | 198 ++++++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_type.h     |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |   6 -
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h |  10 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |   8 +-
 8 files changed, 197 insertions(+), 111 deletions(-)

-- 
1.9.3
