From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-08-05
Date: Wed,  5 Aug 2015 16:52:00 -0700
Message-ID: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36603 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbbHEXwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and e1000e.

Anjali adds support for x772 devices to i40e and i40evf.  With the added
support, x772 supports offloading of the outer UDP transmit and receive
checksum for tunneled packets.  Also supports evicting ATR filters in the
hardware, so update the driver with this new feature set.

Raanan provides several fixes for e1000e, first rectifies the Energy
Efficient Ethernet in Sx code so that it only applies to parts that
actually support EEE in Sx.  Fix whitespace and moved ICH8 related define
to the proper context.  Fixed the ASPM locking which was reported by
Bjorn Helgaas.  Fix a workaround implementation for systime which could
experience a large non-linear increment of the systime value when
checking for overflow.

The following are changes since commit 9dc20a649609c95ce7c5ac4282656ba627b67d49:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (9):
  i40e/i40evf: Add device ids for X722
  i40e/i40evf: Add flags for X722 capabilities
  i40e/i40evf: Update FW API with X722 support
  i40e/i40evf: Update register.h file for X722
  i40e/i40evf: RSS changes for X722
  i40e/i40evf: Add support for writeback on ITR feature for X722
  i40e/i40evf: Add TX/RX outer UDP checksum support for X722
  i40e: Add IWARP support for X722
  i40e/i40evf: Add ATR HW eviction support for X722

Raanan Avargil (5):
  e1000e: Fix EEE in Sx implementation
  e1000e: Cosmetic changes
  e1000e: Fix incorrect ASPM locking
  e1000e: Fix tight loop implementation of systime read algorithm
  e1000e: Increase driver version number

Shannon Nelson (1):
  i40e: Add AQ commands for NVM Update for X722

 drivers/net/ethernet/intel/e1000e/ich8lan.h        |    4 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |   64 +-
 drivers/net/ethernet/intel/e1000e/regs.h           |    5 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |   15 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   48 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  173 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  181 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  129 ++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   11 +
 drivers/net/ethernet/intel/i40e/i40e_register.h    | 1931 +++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   72 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   16 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   39 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   11 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   49 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  172 ++
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |   11 +
 drivers/net/ethernet/intel/i40evf/i40e_register.h  |   62 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   51 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   16 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   35 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   10 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  167 +-
 23 files changed, 3136 insertions(+), 136 deletions(-)

-- 
2.4.3
