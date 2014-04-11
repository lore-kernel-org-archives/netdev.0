From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 00/13][pull request] Intel Wired LAN Driver Updates
Date: Fri, 11 Apr 2014 06:52:50 -0700
Message-ID: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47069 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755655AbaDKNxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb, igbvf, ixgb, ixgbe,
ixgbevf and i40evf.

Mark fixes an issue with ixgbe and ixgbevf by adding a bit to indicate
when workqueues have been initialized.  This permits the register read
error handling from attempting to use them prior to that, which also
generates warnings.  Checking for a detected removal after initializing
the work queues allows the probe function to return an error without
getting the workqueue involved.  Further, if the error_detected
callback is entered before the workqueues are initialized, exit without
recovery since the device initialization was so truncated.

Francois Romieu provides several patches to all the drivers to remove
the open coded skb_cow_head.

Jakub Kicinski provides a fix for igb where last_rx_timestamp should be
updated only when Rx time stamp is read.

Mitch provides a fix for i40evf where a recent change broke the RSS LUT
programming causing it to be programmed with all 0's.

The following are changes since commit 6d39d589bb76ee8a1c6cde6822006ae0053decff:
  net: core: don't account for udp header size when computing seglen
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Francois Romieu (8):
  ixgbe: remove open-coded skb_cow_head
  ixgbevf: remove open-coded skb_cow_head
  e1000: remove open-coded skb_cow_head
  e1000e: remove open-coded skb_cow_head
  igb: remove open-coded skb_cow_head
  igbvf: remove open-coded skb_cow_head
  ixgb: remove open-coded skb_cow_head
  i40evf: remove open-coded skb_cow_head

Jakub Kicinski (2):
  e1000: remove debug messages with function names
  igb: fix last_rx_timestamp usage

Mark Rustad (2):
  ixgbe: Add bit to mark service task initialization
  ixgbevf: Add bit to mark work queue initialization

Mitch A Williams (1):
  i40evf: program RSS LUT correctly

 drivers/net/ethernet/intel/e1000/e1000_hw.c       | 124 ----------------------
 drivers/net/ethernet/intel/e1000/e1000_main.c     |  11 +-
 drivers/net/ethernet/intel/e1000e/netdev.c        |  10 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  10 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  20 +++-
 drivers/net/ethernet/intel/igb/igb.h              |  16 +--
 drivers/net/ethernet/intel/igb/igb_main.c         |  13 +--
 drivers/net/ethernet/intel/igb/igb_ptp.c          |  14 +--
 drivers/net/ethernet/intel/igbvf/netdev.c         |  16 ++-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  28 +++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  20 ++--
 14 files changed, 91 insertions(+), 203 deletions(-)

-- 
1.9.0
