From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from
	lib/hexdump.c instead
Date: Tue, 20 May 2008 15:41:59 -0700
Message-ID: <1211323319.5915.223.camel@brick>
References: <1211135864-8235-1-git-send-email-crquan@gmail.com>
	 <20080520.153611.204837174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: crquan@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:4170 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935482AbYETWmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:42:02 -0400
Received: by py-out-1112.google.com with SMTP id u52so2645794pyb.10
        for <netdev@vger.kernel.org>; Tue, 20 May 2008 15:42:01 -0700 (PDT)
In-Reply-To: <20080520.153611.204837174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: use common hex_asc helpers

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Something like this.

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
1.5.5.1.570.g26b5e



