From: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
Subject: [PATCH 2.6.22.3] ppp: fix output buffer size in
	ppp_decompress_frame
Date: Fri, 17 Aug 2007 20:45:51 +1100
Message-ID: <1187343951.10629.9.camel@traveler>
Reply-To: konstantin.sharlaimov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paulus@samba.org,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Suresh Mahalingam <msuresh_2001@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:16647 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbXHQJqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 05:46:07 -0400
Received: by ug-out-1314.google.com with SMTP id j3so318408ugf
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 02:46:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch addresses the issue with "osize too small" errors in mppe encryption.
The patch fixes the issue with wrong output buffer size being passed to ppp
decompression routine.

Signed-off-by: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
---
As pointed out by Suresh Mahalingam, the issue addressed by 
ppp-fix-osize-too-small-errors-when-decoding patch is not fully resolved yet.
The size of allocated output buffer is correct, however it size passed to
ppp->rcomp->decompress in ppp_generic.c if wrong. The patch fixes that.

--- linux-2.6.21.3/drivers/net/ppp_generic.c.orig	2007-08-17 20:35:03.000000000 +1100
+++ linux-2.6.21.3/drivers/net/ppp_generic.c	2007-08-17 20:35:45.000000000 +1100
@@ -1726,7 +1726,7 @@ ppp_decompress_frame(struct ppp *ppp, st
 		}
 		/* the decompressor still expects the A/C bytes in the hdr */
 		len = ppp->rcomp->decompress(ppp->rc_state, skb->data - 2,
-				skb->len + 2, ns->data, ppp->mru + PPP_HDRLEN);
+				skb->len + 2, ns->data, obuff_size);
 		if (len < 0) {
 			/* Pass the compressed frame to pppd as an
 			   error indication. */

