From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH] Revert "usbnet: drop unneeded check for NULL"
Date: Wed,  5 Sep 2012 21:22:32 +0200
Message-ID: <1346872952-21192-1-git-send-email-oliver@neukum.org>
Cc: Oliver Neukum <oliver@neukum.org>, Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:40117 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758827Ab2IETX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 15:23:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 5d65878d7031b6c39054b282faceff406bb2fda9.
The upper layers call usbnet_start_xmit() with a valid skb.
However cdc_ncm abuses this method by calling it with NULL
to trigger IO for the aggregated private skb holding erlier
packets. Until cdc_ncm is fixed, the check for NULL must
be reintroduced.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/usbnet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 5234d20..8531c1c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1092,7 +1092,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	unsigned long		flags;
 	int retval;
 
-	skb_tx_timestamp(skb);
+	if (skb)
+		skb_tx_timestamp(skb);
 
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
-- 
1.7.7
