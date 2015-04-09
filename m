From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/4] Replace wmb()/rmb() with dma_wmb()/dma_rmb()
 where appropriate, round 2
Date: Wed, 08 Apr 2015 18:49:23 -0700
Message-ID: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702AbbDIBt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 21:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More cleanup of drivers in order to start making use of dma_rmb and dma_wmb
calls.  This is another pass of what I would consider to be low hanging
fruit.  There may be other opportunities to make use of the barriers in the
Mellanox and Chelsio drivers but I didn't want to risk meddling with code I
was not completely familiar with so I am leaving that for future work.

I have revisited the Mellanox driver changes.  This time around I went only
for the sections with a clearly defined pattern.  For dma_wmb I used it
between accesses of the descriptor bits followed by owner or size.  For
dma_wmb I used it to replace rmb following a read of the ownership bit in
the descriptor.

---

Alexander Duyck (4):
      cxgb3/4/4vf: Update drivers to use dma_rmb/wmb where appropriate
      mlx4/mlx5: Use dma_wmb/rmb where appropriate
      i40e/i40evf: Use dma_rmb where appropriate
      e100: Use dma_rmb/wmb where appropriate


 drivers/net/ethernet/chelsio/cxgb3/sge.c      |   20 ++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/sge.c      |    4 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c    |    4 ++--
 drivers/net/ethernet/intel/e100.c             |    6 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c    |   12 ++++++------
 drivers/net/ethernet/mellanox/mlx4/eq.c       |    4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eq.c  |    2 +-
 10 files changed, 31 insertions(+), 31 deletions(-)

--
