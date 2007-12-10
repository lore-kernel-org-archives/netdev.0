From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] ESP: Discard dummy packets introduced in rfc4303
Date: Mon, 10 Dec 2007 23:18:07 +0100
Message-ID: <20071210221807.GH11220@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46704 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935AbXLJWlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 17:41:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4303 introduces dummy packets with a nexthdr value of 59
to implement traffic confidentiality. Such packets need to
be dropped silently and the payload may not be attempted to
be parsed as it consists of random chunk.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.25/net/ipv6/esp6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/esp6.c	2007-12-10 16:06:02.000000000 +0100
+++ net-2.6.25/net/ipv6/esp6.c	2007-12-10 16:08:02.000000000 +0100
@@ -238,6 +238,12 @@
 		}
 		/* ... check padding bits here. Silly. :-) */
 
+		/* RFC4303: Drop dummy packets without any error */
+		if (nexthdr[1] == IPPROTO_NONE) {
+			ret = -EINVAL;
+			goto out;
+		}
+
 		pskb_trim(skb, skb->len - alen - padlen - 2);
 		ret = nexthdr[1];
 	}
