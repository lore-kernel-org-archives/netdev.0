From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/7] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 18:29:58 -0800
Message-ID: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165AbaARCaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 21:30:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates from Emil to ixgbevf.

He cleans up the code by removing the adapter structure as a
parameter from multiple functions in favor of using the ixgbevf_ring
structure and moves hot-path specific statistic int the ring 
structure for anticipated performance gains.

He also removes the Tx/Rx counters for checksum offload and adds 
counters for tx_restart_queue and tx_timeout_count.

Next he makes it so that the first tx_buffer structure acts as a
central storage location for most the skb info we are about to
transmit, then takes advantage of the dma buffer always being
present in the first descriptor and mapped as single allowing a 
call to dma_unmap_single which alleviates the need to check for
DMA mapping in ixgbevf_clean_tx_irq().  

Finally he merges the ixgbevf_tx_map call and the ixgbevf_tx_queue
call into a single function.

Emil Tantilov (7):
  ixgbevf: make use of the dev pointer in the ixgbevf_ring struct
  ixgbevf: move ring specific stats into ring specific structure
  ixgbevf: remove counters for Tx/Rx checksum offload
  ixgbevf: add tx counters
  ixgbevf: make the first tx_buffer a repository for most of the skb
    info
  ixgbevf: redo dma mapping using the tx buffer info
  ixgbevf: merge ixgbevf_tx_map and ixgbevf_tx_queue into a single
    function

 drivers/net/ethernet/intel/ixgbevf/defines.h      |   1 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  62 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  90 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 620 +++++++++++-----------
 4 files changed, 403 insertions(+), 370 deletions(-)

-- 
1.8.5.GIT
