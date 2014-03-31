From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Mon, 31 Mar 2014 16:34:46 -0700
Message-ID: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34702 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbaCaXg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to e1000e, igb, ixgbe, ixgebvf, i40e and
i40evf.

David provides a fix for e1000e to resolve an issue where the device is
capable of transmitting packets but is unable to receive packets until
a previously introduced workaround is called.

Jakub Kicinski provides PTP fixes for ixgbe, which include removing a
redundant if clause and make sure we are not generating both a software and
hardware timestamp.  As well as fix a race condition and leaking skbs
when multiple transmit rings try to claim time stamping.

Jean Sacren fixes a function declaration in ixgbe which was introduced
in commit c97506ab0e22 ("ixgbe: Add check for FW veto bit").  In addition
fixes a function header comment in i40e and fixes the error checking
by binding the check to the pertinent DMA bit mask.

Mark provides several fixes for ixgbe and ixgbevf.  Most notably are fixes
to resolve namespace issues and fix ECU warnings induced by LER for ixgbe
and ixgbevf.

Joe Perches fixes up unnecessary casts in i40e and i40evf.

Peter Senna Tschudin fixes igb to use pci_iounmap when the virtual mapping
was done with pci_iomap.
 
The following are changes since commit 0b70195e0c3206103be991e196c26fcf168d0334:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

David Ertman (1):
  e1000e: Fix no connectivity when driver loaded with cable out

Jakub Kicinski (3):
  ixgbe: remove redundant if clause from PTP work
  ixgbe: never generate both software and hardware timestamps
  ixgbe: fix race conditions on queuing skb for HW time stamp

Jean Sacren (3):
  ixgbe: fix ixgbe_check_reset_blocked() declaration
  i40e: fix function kernel doc description
  i40e/i40evf: fix error checking path

Joe Perches (2):
  i40e/i40evf: Remove addressof casts to same type
  i40e: Remove casts of pointer to same type

Mark Rustad (3):
  ixgbevf: Change ixgbe_read_reg to ixgbevf_read_reg
  ixgbe: Fix rcu warnings induced by LER
  ixgbevf: Fix rcu warnings induced by LER

Peter Senna Tschudin (1):
  INTEL-IGB: Convert iounmap to pci_iounmap

 drivers/net/ethernet/intel/e1000e/netdev.c        | 20 +++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_common.c     |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 11 ++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c   |  3 +--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   | 11 ++++----
 drivers/net/ethernet/intel/igb/igb_main.c         |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 31 +++++++++++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      |  7 +++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  8 +++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 26 ++++++++++++++-----
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  6 ++---
 17 files changed, 92 insertions(+), 52 deletions(-)

-- 
1.9.0
