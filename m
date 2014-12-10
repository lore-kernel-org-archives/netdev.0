From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/6] net: Alloc NAPI page frags from their own pool
Date: Tue, 09 Dec 2014 19:40:35 -0800
Message-ID: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, davem@davemloft.net, eric.dumazet@gmail.com,
	brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370AbaLJDkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 22:40:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements a means of allocating page fragments without
the need for the local_irq_save/restore in __netdev_alloc_frag.  By doing
this I am able to decrease packet processing time by 11ns per packet in my
test environment.

---

Alexander Duyck (6):
      net: Split netdev_alloc_frag into __alloc_page_frag and add __napi_alloc_frag
      net: Pull out core bits of __netdev_alloc_skb and add __napi_alloc_skb
      ethernet/intel: Use napi_alloc_skb
      cxgb: Use napi_alloc_skb instead of netdev_alloc_skb_ip_align
      ethernet/realtek: use napi_alloc_skb instead of netdev_alloc_skb_ip_align
      ethernet/broadcom: Use napi_alloc_skb instead of netdev_alloc_skb_ip_align


 drivers/net/ethernet/broadcom/b44.c             |    2 
 drivers/net/ethernet/broadcom/bcm63xx_enet.c    |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 
 drivers/net/ethernet/chelsio/cxgb/sge.c         |   11 +
 drivers/net/ethernet/intel/e1000/e1000_main.c   |    2 
 drivers/net/ethernet/intel/e1000e/netdev.c      |    2 
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |    4 
 drivers/net/ethernet/intel/igb/igb_main.c       |    3 
 drivers/net/ethernet/intel/ixgb/ixgb_main.c     |    6 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    4 
 drivers/net/ethernet/realtek/8139cp.c           |    2 
 drivers/net/ethernet/realtek/8139too.c          |    2 
 drivers/net/ethernet/realtek/r8169.c            |    2 
 include/linux/skbuff.h                          |   11 +
 net/core/dev.c                                  |    2 
 net/core/skbuff.c                               |  191 +++++++++++++++++------
 16 files changed, 178 insertions(+), 70 deletions(-)

--
