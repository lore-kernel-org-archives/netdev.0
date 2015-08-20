From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates 2015-08-19
Date: Wed, 19 Aug 2015 17:57:50 -0700
Message-ID: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbbHTA6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Anjali provides a fix for i40e where the part is not receiving multicast
or VLAN tagged packets when in promiscuous mode.  This can occur when a
software bridge is created on top of the device.  Added a new header for
helper functions for both the PF and VF drivers.  Fixed the legacy and MSI
interrupt mode in the driver, which was non-existent before since we
were assuming MSIX was the only mode that the driver ran in.  Fixed the
i40evf driver, where the wrong defines were getting used in the VF
driver.

Mitch fixes a sparse warning about comparing __le16 to u16 so use
le16_to_cpu() to resolve the warning.  Also fixed a dyslexic spelling
of invalid.

Shannon adds port.crc_errors to receive CRC error counter, since it
is a receive counter.

Catherine provides a fix to move the stopping of the service task and
flow director to i40e_shutdown() instead of i40e_suspend().

Greg fixes the ethtool offline diagnostic with netqueues, which just need
to be treated the same as virtual functions when someone wants to run the
ethtool offline diagnostic test.  Also fixed up code comments for the
i40e ethtool diagnostic test function.  Cleans up redundant and unneeded
messages, since the kernel notifies all VXLAN capable registered drivers,
so no need to log this.

Neerav adds the ability to update statistics per VEB per traffic class
and dump it via ethtool.

Jingjing adds support for virtual channel offload to support receive
polling mode in the VF driver.

The following are changes since commit def63be85fe774477fb66043003e5b2ee748c4fa:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (6):
  i40e: Set defport behavior for the Main VSI when in promiscuous mode
  i40e/i40evf: Move helper functions to a header file
  i40e: Fix legacy interrupt mode in the driver
  i40evf: Use the correct defines to match the VF registers
  i40evf: Remove PF specific register definitions from the VF
  i40e/i40evf: add VIRTCHNL_VF_OFFLOAD flag

Catherine Sullivan (2):
  i40e: Move function calls to i40e_shutdown instead of i40e_suspend
  i40e/i40evf: Bump i40e to 1.3.9 and i40evf to 1.3.5

Greg Rose (3):
  i40e: Fix ethtool offline diagnostic with netqueues
  i40e: Fix comment for ethtool diagnostic link test
  i40e: Remove redundant and unneeded messages

Mitch Williams (2):
  i40e: don't degrade __le16
  i40e: correct spelling error

Neerav Parikh (2):
  i40e/i40evf: Add capability to gather VEB per TC stats
  i40e/i40evf: Cache the CEE TLV status returned from firmware

Shannon Nelson (1):
  i40e: add RX to port CRC errors label

 drivers/net/ethernet/intel/i40e/i40e.h             |    3 +
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |    4 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   54 +-
 drivers/net/ethernet/intel/i40e/i40e_helper.h      |  102 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  180 +-
 drivers/net/ethernet/intel/i40e/i40e_register.h    |    7 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |    9 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |    1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   19 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   17 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |    2 +-
 drivers/net/ethernet/intel/i40evf/i40e_helper.h    |  102 +
 drivers/net/ethernet/intel/i40evf/i40e_register.h  | 3093 --------------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   28 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |    9 +
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |    1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  122 +-
 17 files changed, 427 insertions(+), 3326 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_helper.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_helper.h

-- 
2.4.3
