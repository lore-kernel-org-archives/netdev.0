From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/9] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 15:36:30 -0800
Message-ID: <1390001799-19425-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55373 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbaAQXhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 18:37:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e.  

Neerav implements DCB and DCBNL support and adds DCB options
to Kconfig.  DCB is disabled by default.

Anjali refactors flow control director to fix inconsistencies
that were preventing clean unloads of the driver, move the
queues for handling flow director error into their own hardware
VSI and implement a corrected version of the basic ethtool add 
ntuple rule.

Jesse provides fixes for a compiler warning, firmware workaround,
white space fixes and renames some defines.

Shannon reworks the device ID #defines to follow the
DEV_ID_ convention followed by our other drivers.

Jesse Brandeburg (4):
  i40e: fix compile warning on checksum_local
  i40e: Change firmware workaround
  i40e: whitespace fixes
  i40e: rename defines
 
Anjali Singhai Jain (1):
  i40e: refactor flow director

Neerav Parikh (3):
  i40e: implement DCB support infastructure
  i40e: add DCB and DCBNL support
  i40e: add DCB option to Kconfig

Shannon Nelson (1):
  i40e: Fix device ID define names to align to standard

 drivers/net/ethernet/intel/Kconfig                 |   8 +
 drivers/net/ethernet/intel/i40e/Makefile           |   2 +
 drivers/net/ethernet/intel/i40e/i40e.h             |  21 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 145 +++-
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         | 469 +++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_dcb.h         | 107 +++
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      | 316 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  59 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  17 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 733 +++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  22 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  45 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  24 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  32 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   2 +-
 18 files changed, 1711 insertions(+), 299 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_dcb.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_dcb.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c

-- 
1.8.5.GIT
