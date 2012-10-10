From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 2/8] vxlan: fix byte order in hash function
Date: Tue, 09 Oct 2012 23:35:47 -0700
Message-ID: <20121010063623.471596387@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52281 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab2JJGjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:23 -0400
Content-Disposition: inline; filename=vxlan-byte-order.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shift was wrong direction causing packets to hash based on
other parts of the ethernet header, not the address.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxlan.c	2012-10-09 18:08:31.722465071 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 18:08:32.630456072 -0700
@@ -228,9 +228,9 @@ static u32 eth_hash(const unsigned char
 
 	/* only want 6 bytes */
 #ifdef __BIG_ENDIAN
-	value <<= 16;
-#else
 	value >>= 16;
+#else
+	value <<= 16;
 #endif
 	return hash_64(value, FDB_HASH_BITS);
 }
