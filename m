From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Sat, 17 Sep 2011 01:04:24 -0700
Message-ID: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab1IQIEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 04:04:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgb and igb. The ixgb patch
is a trivial fix.  The remaining patches are for igb to do the following:

  - cleanup/consolidate Tx descriptors
  - trivial fix to remove _adv/_ADV since igb uses only advanced
    descriptors
  - performance enhancements to help with  general and routing

This series of igb patches is the first of three to update/cleanup the igb
driver by Alex.  So there are additional patches/changes coming to complete
this work.

The following are changes since commit 765cf9976e937f1cfe9159bf4534967c8bf8eb6d:
  tcp: md5: remove one indirection level in tcp_md5sig_pool
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (12):
  igb: Update RXDCTL/TXDCTL configurations
  igb: Update max_frame_size to account for an optional VLAN tag if
    present
  igb: drop support for single buffer mode
  igb: streamline Rx buffer allocation and cleanup
  igb: update ring and adapter structure to improve performance
  igb: Refactor clean_rx_irq to reduce overhead and improve performance
  igb: drop the "adv" off function names relating to descriptors
  igb: Replace E1000_XX_DESC_ADV with IGB_XX_DESC
  igb: Remove multi_tx_table and simplify igb_xmit_frame
  igb: Make Tx budget for NAPI user adjustable
  igb: split buffer_info into tx_buffer_info and rx_buffer_info
  igb: Consolidate creation of Tx context descriptors into a single
    function

Jesse Brandeburg (1):
  ixgb: eliminate checkstack warnings

 drivers/net/ethernet/intel/igb/igb.h         |  160 +++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   36 +-
 drivers/net/ethernet/intel/igb/igb_main.c    |  972 +++++++++++++-------------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c  |   10 +-
 4 files changed, 586 insertions(+), 592 deletions(-)

-- 
1.7.6
