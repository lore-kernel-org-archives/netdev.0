From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Tue, 24 Nov 2009 17:20:12 -0800
Message-ID: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1232 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933738AbZKYBUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes the skb_dma_map and skb_dma_unmap function calls.
The reason for this change is because the use of skb_dma_map/unmap can lead
to serious issues when HW IOMMU is enabled.  This is because each mapping
of the skb with a HW IOMMU enabled results in a new set of DMA mappings.
This in turn leads to issues when skbs are cloned for uses such as
bridging or pktgen because each transmitting device will update the skb
shared info structure resulting in some mappings being overwritten, and others
being freed multiple times.

I am looking for input specifically on the tg3, be2net, and bnx2 driver
patches as I am not very familiar with them and I am not certain if
additional changes are required.

I have included the changes for the Intel wired Ethernet drivers as a
reference.

---

Alexander Duyck (10):
      skbuff: remove skb_dma_map/unmap
      tg3: remove use of skb_dma_map/unmap
      be2net: remove use of skb_dma_map/unmap
      bnx2: remove skb_dma_map/unmap calls from driver
      igbvf: remove skb_dma_map/unmap call from drivers
      igb: remove use of skb_dma_map from driver
      ixgbe: remove skb_dma_map/unmap calls from driver
      ixgb: remove use of skb_dma_map from ixgb
      e1000: remove use of skb_dma_map from e1000 driver
      e1000e: remove use of skb_dma_map from e1000e driver


 drivers/net/benet/be_main.c    |   37 ++++++---
 drivers/net/bnx2.c             |   74 ++++++++++++++---
 drivers/net/bnx2.h             |    1 
 drivers/net/e1000/e1000.h      |    1 
 drivers/net/e1000/e1000_main.c |   56 +++++++++----
 drivers/net/e1000e/e1000.h     |    9 +-
 drivers/net/e1000e/netdev.c    |   59 +++++++++-----
 drivers/net/igb/igb.h          |    5 +
 drivers/net/igb/igb_main.c     |   69 ++++++++++++----
 drivers/net/igbvf/igbvf.h      |    1 
 drivers/net/igbvf/netdev.c     |   65 ++++++++++++---
 drivers/net/ixgb/ixgb.h        |    1 
 drivers/net/ixgb/ixgb_main.c   |   60 +++++++++-----
 drivers/net/ixgbe/ixgbe.h      |    1 
 drivers/net/ixgbe/ixgbe_main.c |   63 +++++++++++----
 drivers/net/tg3.c              |  173 ++++++++++++++++++++++++++++++----------
 drivers/net/tg3.h              |    6 -
 include/linux/skbuff.h         |    8 --
 net/core/Makefile              |    1 
 net/core/skb_dma_map.c         |   65 ---------------
 20 files changed, 508 insertions(+), 247 deletions(-)
 delete mode 100644 net/core/skb_dma_map.c

-- 
