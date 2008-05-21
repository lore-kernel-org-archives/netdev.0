From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from lib/hexdump.c instead
Date: Wed, 21 May 2008 10:27:41 +0800
Message-ID: <91b13c310805201927k4fccf8dcwa3fabe61777b2eda@mail.gmail.com>
References: <1211135864-8235-1-git-send-email-crquan@gmail.com>
	 <20080520.153611.204837174.davem@davemloft.net>
	 <1211323212.5915.220.camel@brick>
	 <20080520.154551.54365414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:43169 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810AbYEUC1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 22:27:42 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1282799tic.23
        for <netdev@vger.kernel.org>; Tue, 20 May 2008 19:27:41 -0700 (PDT)
In-Reply-To: <20080520.154551.54365414.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From bc47e710a3ebd8a5989404f711a051b6516d01ed Mon Sep 17 00:00:00 2001
From: Denis Cheng <crquan@gmail.com>
Date: Wed, 21 May 2008 09:43:32 +0800
Subject: [PATCH] net/ipv4/arp.c: Use common hex_asc helpers

Here the local hexbuf is a duplicate of global const char hex_asc from
lib/hexdump.c, except the hex letters' cases:

	const char hexbuf[] = "0123456789ABCDEF";

	const char hex_asc[] = "0123456789abcdef";

and here to print HW addresses, the hex cases are not significant.

Thanks to Harvey Harrison to introduce the hex_asc_hi/hex_asc_lo helpers.

Signed-off-by: Denis Cheng <crquan@gmail.com>
Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/arp.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 418862f..9b539fa 100644
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
+		hbuffer[k++] = hex_asc_hi(n->ha[j]);
+		hbuffer[k++] = hex_asc_lo(n->ha[j]);
 		hbuffer[k++] = ':';
 	}
 	hbuffer[--k] = 0;
-- 
1.5.4.3
