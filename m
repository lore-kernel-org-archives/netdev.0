From: Dennis Aberilla <dennis.aberilla@mimomax.com>
Subject: [PATCH] drivers/net: ks8842 Fix crash on received packet when in
	PIO mode.
Date: Mon, 30 May 2011 09:46:54 +1200
Message-ID: <20110529214652.GA4707@dens-work>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: info@mocean-labs.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:56674 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752792Ab1E2VrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 17:47:03 -0400
Received: by mail-pv0-f179.google.com with SMTP id 33so1675676pvf.24
        for <netdev@vger.kernel.org>; Sun, 29 May 2011 14:47:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a driver crash during packet reception due to not enough
bytes allocated in the skb. Since the loop reads out 4 bytes at a time, we
need to allow for up to 3 bytes of slack space.

Signed-off-by: Dennis Aberilla <denzzzhome@yahoo.com>

---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index f0d8346..9bd0f55 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -662,7 +662,7 @@ static void ks8842_rx_frame(struct net_device *netdev,
 
 	/* check the status */
 	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
-		struct sk_buff *skb = netdev_alloc_skb_ip_align(netdev, len);
+		struct sk_buff *skb = netdev_alloc_skb_ip_align(netdev, len + 3);
 
 		if (skb) {
 

--

Thanks.

|Dennis
=======================================================================
This email, including any attachments, is only for the intended
addressee.  It is subject to copyright, is confidential and may be
the subject of legal or other privilege, none of which is waived or
lost by reason of this transmission.
If the receiver is not the intended addressee, please accept our
apologies, notify us by return, delete all copies and perform no
other act on the email.
Unfortunately, we cannot warrant that the email has not been
altered or corrupted during transmission.
=======================================================================

