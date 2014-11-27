From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 0/3] net: Alloc NAPI page frags from their own pool
Date: Wed, 26 Nov 2014 16:05:50 -0800
Message-ID: <20141126235900.1617.10008.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brouer@redhat.com,
	jeffrey.t.kirsher@intel.com, eric.dumazet@gmail.com,
	ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbaK0AGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2014 19:06:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements a means of allocating page fragments without
the need for the local_irq_save/restore in __netdev_alloc_frag.  By doing
this I am able to decrease packet processing time by 11ns per packet in my
test environment.

---

Alexander Duyck (3):
      net: Split netdev_alloc_frag into __alloc_page_frag and add __napi_alloc_frag
      net: Pull out core bits of __netdev_alloc_skb and add __napi_alloc_skb
      fm10k/igb/ixgbe: Use napi_alloc_skb


 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    4 -
 drivers/net/ethernet/intel/igb/igb_main.c     |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 -
 include/linux/skbuff.h                        |   11 ++
 net/core/dev.c                                |    2 
 net/core/skbuff.c                             |  160 ++++++++++++++++++-------
 6 files changed, 133 insertions(+), 51 deletions(-)

--
