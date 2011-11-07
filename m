From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH v2] usbnet: fix oops in usbnet_start_xmit
Date: Mon, 07 Nov 2011 18:54:58 +0300
Message-ID: <20111107145458.29997.79829.stgit@zurg>
References: <20111106183337.5379.4356.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Riesch <michael@riesch.at>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, devel@openvz.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59393 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971Ab1KGOzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 09:55:02 -0500
Received: by bke11 with SMTP id 11so3653917bke.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 06:55:01 -0800 (PST)
In-Reply-To: <20111106183337.5379.4356.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the bug added in commit v3.1-rc7-1055-gf9b491e
SKB can be NULL at this point, at least for cdc-ncm.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 drivers/net/usb/usbnet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 7d60821..fae0fbd 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1057,7 +1057,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	unsigned long		flags;
 	int retval;
 
-	skb_tx_timestamp(skb);
+	if (skb)
+		skb_tx_timestamp(skb);
 
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
