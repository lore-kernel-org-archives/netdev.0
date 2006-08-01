From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: only set err in rawv6_bind() when necessary
Date: Tue, 01 Aug 2006 13:06:03 -0400
Message-ID: <44CF89FB.2060208@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090901070102000200040401"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:40884 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751668AbWHARGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:06:46 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090901070102000200040401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The variable 'err' is set in rawv6_bind() before the address check fails 
instead of after, moved inside if() statement.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------090901070102000200040401
Content-Type: text/x-patch;
 name="raw.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="raw.patch"

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8a30cd8..072b28b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -240,10 +240,10 @@ static int rawv6_bind(struct sock *sk, s
 		 */
 		v4addr = LOOPBACK4_IPV6;
 		if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-			err = -EADDRNOTAVAIL;
 			if (!ipv6_chk_addr(&addr->sin6_addr, dev, 0)) {
 				if (dev)
 					dev_put(dev);
+				err = -EADDRNOTAVAIL;
 				goto out;
 			}
 		}

--------------090901070102000200040401--
