From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 0/7] rhashtable: Introduce inlined interface
Date: Sat, 21 Mar 2015 14:14:03 +1100
Message-ID: <20150321031403.GA25793@gondor.apana.org.au>
References: <20150320212844.GC23301@gondor.apana.org.au>
 <20150320.181715.477950273744674777.davem@davemloft.net>
 <20150320222106.GA24241@gondor.apana.org.au>
 <20150320.183701.615035998227406804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:55091 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCUDON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 23:14:13 -0400
Content-Disposition: inline
In-Reply-To: <20150320.183701.615035998227406804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 06:37:01PM -0400, David Miller wrote:
>
> Yep, but I'm saying this alternative expression allows to remove the
> trailer which even made me say "what's this for?"

OK, this patch removes trailer.

---8<---
netlink: Remove netlink_compare_arg.trailer

Instead of computing the offset from trailer, this patch computes
netlink_compare_arg_len from the offset of portid and then adds 4
to it.  This allows trailer to be removed.

Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 72c6b55..6517921 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -974,10 +974,11 @@ struct netlink_compare_arg
 {
 	possible_net_t pnet;
 	u32 portid;
-	char trailer[];
 };
 
-#define netlink_compare_arg_len offsetof(struct netlink_compare_arg, trailer)
+/* Doing sizeof directly may yield 4 extra bytes on 64-bit. */
+#define netlink_compare_arg_len \
+	(offsetof(struct netlink_compare_arg, portid) + sizeof(u32))
 
 static inline int netlink_compare(struct rhashtable_compare_arg *arg,
 				  const void *ptr)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
