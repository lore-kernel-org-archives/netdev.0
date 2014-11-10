From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 3/5] phonet: Replace calls to __skb_alloc_page with
 __netdev_alloc_page
Date: Mon, 10 Nov 2014 11:52:13 -0800
Message-ID: <20141110195213.16182.95471.stgit@ahduyck-vm-fedora20>
References: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbaKJTwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 14:52:31 -0500
In-Reply-To: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the calls to __skb_alloc_page that are passed NULL with calls to
__netdev_alloc_page.

Cc: Oliver Neukum <oliver@neukum.org>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/usb/cdc-phonet.c           |    2 +-
 drivers/usb/gadget/function/f_phonet.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 2ec1500..fd88da8 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -130,7 +130,7 @@ static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = __skb_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
+	page = __netdev_alloc_page(gfp_flags | __GFP_NOMEMALLOC);
 	if (!page)
 		return -ENOMEM;
 
diff --git a/drivers/usb/gadget/function/f_phonet.c b/drivers/usb/gadget/function/f_phonet.c
index b9cfc15..1a5be3a 100644
--- a/drivers/usb/gadget/function/f_phonet.c
+++ b/drivers/usb/gadget/function/f_phonet.c
@@ -303,7 +303,7 @@ pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = __skb_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
+	page = __netdev_alloc_page(gfp_flags | __GFP_NOMEMALLOC);
 	if (!page)
 		return -ENOMEM;
 
