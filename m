From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 1/2] pasemi_mac: Don't set replace-source-address
	descriptor bits
Date: Tue, 6 Nov 2007 22:20:39 -0600
Message-ID: <20071107042039.GD22637@lixom.net>
References: <20071107042001.GC22637@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56835 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002AbXKGELU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 23:11:20 -0500
Content-Disposition: inline
In-Reply-To: <20071107042001.GC22637@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't use the "replace source address with local MAC address" bits, since
it causes problems on some variations of the hardware due to an erratum.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -1126,7 +1126,7 @@ static int pasemi_mac_start_tx(struct sk
 	unsigned long flags;
 	int i, nfrags;
 
-	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
+	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_CRC_PAD;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const unsigned char *nh = skb_network_header(skb);
