From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/5] Replace __skb_alloc_pages with much simpler
 function
Date: Mon, 10 Nov 2014 11:51:50 -0800
Message-ID: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771AbaKJTwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 14:52:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series replaces __skb_alloc_pages with a much simpler function,
__netdev_alloc_pages.  The main difference between the two is that
__skb_alloc_pages had an sk_buff pointer that was being passed as NULL in
call places where it was called.  In a couple of cases the NULL was passed
by variable and this led to unnecessary code being run.

As such in order to simplify things the __netdev_alloc_pages call only
takes a mask and the page order being requested.  In addition it takes
advantage of several behaviors already built into the page allocator so
that it can just set GFP flags unconditionally.

---

Alexander Duyck (5):
      net: Add netdev Rx page allocation function
      cxgb4/cxgb4vf: Replace __skb_alloc_page with __netdev_alloc_page
      phonet: Replace calls to __skb_alloc_page with __netdev_alloc_page
      fm10k/igb/ixgbe: Replace __skb_alloc_page with netdev_alloc_page
      net: Remove __skb_alloc_page and __skb_alloc_pages


 drivers/net/ethernet/chelsio/cxgb4/sge.c      |    6 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c    |    7 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 -
 drivers/net/ethernet/intel/igb/igb_main.c     |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 -
 drivers/net/usb/cdc-phonet.c                  |    2 -
 drivers/usb/gadget/function/f_phonet.c        |    2 -
 include/linux/skbuff.h                        |   61 ++++++++++++++-----------
 8 files changed, 45 insertions(+), 40 deletions(-)

--
