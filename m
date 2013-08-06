From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v3 2/4] USB: XHCI: mark no_sg_constraint
Date: Tue,  6 Aug 2013 08:52:47 +0800
Message-ID: <1375750370-18194-3-git-send-email-ming.lei@canonical.com>
References: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	Alan Stern <stern@rowland.harvard.edu>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34280 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab3HFAxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 20:53:24 -0400
In-Reply-To: <1375750370-18194-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch marks all xHCI controllers as no_sg_constraint
since xHCI supports building packet from discontinuous buffers.

Cc: Alan Stern <stern@rowland.harvard.edu>
Acked-by: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/host/xhci.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/usb/host/xhci.c b/drivers/usb/host/xhci.c
index 2c49f00..6e2ac57 100644
--- a/drivers/usb/host/xhci.c
+++ b/drivers/usb/host/xhci.c
@@ -4841,6 +4841,10 @@ int xhci_gen_setup(struct usb_hcd *hcd, xhci_get_quirks_t get_quirks)
 
 	/* Accept arbitrarily long scatter-gather lists */
 	hcd->self.sg_tablesize = ~0;
+
+	/* support to build packet from discontinuous buffers */
+	hcd->self.no_sg_constraint = 1;
+
 	/* XHCI controllers don't stop the ep queue on short packets :| */
 	hcd->self.no_stop_on_short = 1;
 
-- 
1.7.9.5
