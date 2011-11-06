From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH] usbnet: fix oops in usbnet_start_xmit
Date: Sun, 06 Nov 2011 22:33:37 +0300
Message-ID: <20111106183337.5379.4356.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	devel@openvz.org, Michael Riesch <michael@riesch.at>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46007 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754269Ab1KFSdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 13:33:51 -0500
Received: by bke11 with SMTP id 11so3116937bke.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 10:33:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
SKB can be NULL at this point, at least for cdc-ncm.
Let's call skb_tx_timestamp() after driver specific tx-fixup hacks.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 drivers/net/usb/usbnet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 7d60821..485be70 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1057,8 +1057,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	unsigned long		flags;
 	int retval;
 
-	skb_tx_timestamp(skb);
-
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
 	if (info->tx_fixup) {
@@ -1075,6 +1073,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	}
 	length = skb->len;
 
+	skb_tx_timestamp(skb);
+
 	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
 		netif_dbg(dev, tx_err, dev->net, "no urb\n");
 		goto drop;
