From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from lib/hexdump.c instead
Date: Mon, 19 May 2008 02:37:44 +0800
Message-ID: <1211135864-8235-1-git-send-email-crquan@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:58469 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756520AbYERSh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 14:37:57 -0400
Received: by yw-out-2324.google.com with SMTP id 9so938850ywe.1
        for <netdev@vger.kernel.org>; Sun, 18 May 2008 11:37:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here the local hexbuf is a duplicate of global const char hex_asc from
lib/hexdump.c, except the hex letters' cases:

const char hexbuf[] = "0123456789ABCDEF";

const char hex_asc[] = "0123456789abcdef";

and here to print HW addresses, the hex cases are not significant.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/ipv4/arp.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 418862f..f460fa0 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1288,7 +1288,6 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 				   struct neighbour *n)
 {
 	char hbuffer[HBUFFERLEN];
-	const char hexbuf[] = "0123456789ABCDEF";
 	int k, j;
 	char tbuf[16];
 	struct net_device *dev = n->dev;
@@ -1302,8 +1301,8 @@ static void arp_format_neigh_entry(struct seq_file *seq,
 	else {
 #endif
 	for (k = 0, j = 0; k < HBUFFERLEN - 3 && j < dev->addr_len; j++) {
-		hbuffer[k++] = hexbuf[(n->ha[j] >> 4) & 15];
-		hbuffer[k++] = hexbuf[n->ha[j] & 15];
+		hbuffer[k++] = hex_asc[(n->ha[j] >> 4) & 15];
+		hbuffer[k++] = hex_asc[n->ha[j] & 15];
 		hbuffer[k++] = ':';
 	}
 	hbuffer[--k] = 0;
-- 
1.5.5.1

