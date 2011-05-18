From: Dennis Aberilla <dennis.aberilla@mimomax.com>
Subject: [PATCH] drivers/net: ks8842 Fix crash on received packet when in
	PIO mode.
Date: Thu, 19 May 2011 10:59:47 +1200
Message-ID: <20110518225945.GB6416@dens-work>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: info@mocean-labs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:55803 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755350Ab1ERW7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:59:54 -0400
Received: by mail-px0-f172.google.com with SMTP id 6so1567452pxi.3
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 15:59:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes a kernel crash during packet reception due to not enough allocated bytes for the skb. This applies to the driver when running in PIO mode in an ISA bus setup.

Signed-off-by: Dennis Aberilla <denzzzhome@yahoo.com>

---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index f0d8346..9069aee 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -662,7 +662,7 @@ static void ks8842_rx_frame(struct net_device *netdev,
 
 	/* check the status */
 	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
-		struct sk_buff *skb = netdev_alloc_skb_ip_align(netdev, len);
+		struct sk_buff *skb = netdev_alloc_skb_ip_align(netdev, len + 2);
 
 		if (skb) {
 


--

Using mutt this time.

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

