From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 2/4] USB: XHCI: mark no_sg_limit
Date: Sat,  3 Aug 2013 10:46:35 +0800
Message-ID: <1375497998-7424-3-git-send-email-ming.lei@canonical.com>
References: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	Alan Stern <stern@rowland.harvard.edu>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:58277 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512Ab3HCCr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 22:47:56 -0400
In-Reply-To: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch marks all xHCI controllers as no_sg_limit since
xHCI supports building packet from discontinuous buffers.

Cc: Alan Stern <stern@rowland.harvard.edu>
Acked-by: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/host/xhci.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/usb/host/xhci.c b/drivers/usb/host/xhci.c
index 2c49f00..541b155 100644
--- a/drivers/usb/host/xhci.c
+++ b/drivers/usb/host/xhci.c
@@ -4841,6 +4841,10 @@ int xhci_gen_setup(struct usb_hcd *hcd, xhci_get_quirks_t get_quirks)
 
 	/* Accept arbitrarily long scatter-gather lists */
 	hcd->self.sg_tablesize = ~0;
+
+	/* support to build packet from discontinuous buffers */
+	hcd->self.no_sg_limit = 1;
+
 	/* XHCI controllers don't stop the ep queue on short packets :| */
 	hcd->self.no_stop_on_short = 1;
 
-- 
1.7.9.5
