From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ipx: header length validation needed
Date: Mon, 7 Aug 2006 16:36:02 -0700
Message-ID: <20060807163602.5c7a4a65@localhost.localdomain>
References: <20060807134636.30f8b779@localhost.localdomain>
	<20060807.162433.26101101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30186 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932411AbWHGXgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 19:36:46 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060807.162433.26101101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch will linearize and check there is enough data.
It handles the pprop case as well as avoiding a whole audit of
the routing code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- a/net/ipx/af_ipx.c	2006-08-07 13:45:59.000000000 -0700
+++ b/net/ipx/af_ipx.c	2006-08-07 16:34:00.000000000 -0700
@@ -1649,7 +1649,8 @@
 	ipx_pktsize	= ntohs(ipx->ipx_pktsize);
 	
 	/* Too small or invalid header? */
-	if (ipx_pktsize < sizeof(struct ipxhdr) || ipx_pktsize > skb->len)
+	if (ipx_pktsize < sizeof(struct ipxhdr)
+	   || !pskb_may_pull(skb, ipx_pktsize))
 		goto drop;
                         
 	if (ipx->ipx_checksum != IPX_NO_CHECKSUM &&
