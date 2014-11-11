From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v3 0/5] Replace __skb_alloc_pages with simpler
 function
Date: Tue, 11 Nov 2014 09:26:26 -0800
Message-ID: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbaKKR0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:26:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series replaces __skb_alloc_pages with a much simpler function,
__dev_alloc_pages.  The main difference between the two is that
__skb_alloc_pages had an sk_buff pointer that was being passed as NULL in
call places where it was called.  In a couple of cases the NULL was passed
by variable and this led to unnecessary code being run.

As such in order to simplify things the __dev_alloc_pages call only takes a
mask and the page order being requested.  In addition it takes advantage of
several behaviors already built into the page allocator so that it can just
set GFP flags unconditionally.

v2: Renamed functions to dev_alloc_page(s) instead of netdev_alloc_page(s)
    Removed __GFP_COLD flag from usb code as it was redundant
v3: Update patch descriptions and subjects to match changes in v2

---

Alexander Duyck (5):
      net: Add device Rx page allocation function
      cxgb4/cxgb4vf: Replace __skb_alloc_page with __dev_alloc_page
      phonet: Replace calls to __skb_alloc_page with __dev_alloc_page
      fm10k/igb/ixgbe: Replace __skb_alloc_page with dev_alloc_page
      net: Remove __skb_alloc_page and __skb_alloc_pages


 drivers/net/ethernet/chelsio/cxgb4/sge.c      |    6 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c    |    7 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |    2 -
 drivers/net/ethernet/intel/igb/igb_main.c     |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 -
 drivers/net/usb/cdc-phonet.c                  |    6 +-
 drivers/usb/gadget/function/f_phonet.c        |    6 +-
 include/linux/skbuff.h                        |   61 ++++++++++++++-----------
 8 files changed, 49 insertions(+), 44 deletions(-)

--
