From: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [net-next PATCH v2 0/5] Replace __skb_alloc_pages with simpler
 function
Date: Tue, 11 Nov 2014 09:10:43 -0800
Message-ID: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

---

Alexander Duyck (5):
      net: Add device Rx page allocation function
      cxgb4/cxgb4vf: Replace __skb_alloc_page with __netdev_alloc_page
      phonet: Replace calls to __skb_alloc_page with __netdev_alloc_page
      fm10k/igb/ixgbe: Replace __skb_alloc_page with netdev_alloc_page
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
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
