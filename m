From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [09/10] pasemi_mac: Fix RX checksum flags
Date: Wed, 22 Aug 2007 09:13:24 -0500
Message-ID: <20070822141324.GJ16830@lixom.net>
References: <20070817205413.548020000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:45802 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762460AbXHVPQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:16:45 -0400
Content-Disposition: inline; filename=pasemi_mac-rx-checksum-fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RX side flag to use is CHECKSUM_UNNECESSARY, not CHECKSUM_COMPLETE.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: mainline/drivers/net/pasemi_mac.c
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.c
+++ mainline/drivers/net/pasemi_mac.c
@@ -534,7 +534,7 @@ static int pasemi_mac_clean_rx(struct pa
 		skb_put(skb, len);
 
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
-			skb->ip_summed = CHECKSUM_COMPLETE;
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
 		} else

--
