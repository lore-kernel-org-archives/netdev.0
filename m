From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: inet: Replace left-over references to inet->cork
Date: Wed, 2 Mar 2011 14:15:17 +0800
Message-ID: <20110302061517.GA17891@gondor.apana.org.au>
References: <20110301123519.GA7453@gondor.apana.org.au> <E1PuOop-0001xh-HK@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45373 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757961Ab1CBGPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 01:15:32 -0500
Content-Disposition: inline
In-Reply-To: <E1PuOop-0001xh-HK@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 08:36:47PM +0800, Herbert Xu wrote:
> inet: Remove explicit write references to sk/inet in ip_append_data

Just found a couple of spots where inet->cork was still used
instead of just cork.

inet: Replace left-over references to inet->cork

The patch to replace inet->cork with cork left out two spots in
__ip_append_data that can result in bogus packet construction.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 460308c..3e8637c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -789,7 +789,7 @@ static int __ip_append_data(struct sock *sk, struct sk_buff_head *queue,
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
 
-	struct ip_options *opt = inet->cork.opt;
+	struct ip_options *opt = cork->opt;
 	int hh_len;
 	int exthdrlen;
 	int mtu;
@@ -803,7 +803,7 @@ static int __ip_append_data(struct sock *sk, struct sk_buff_head *queue,
 	exthdrlen = transhdrlen ? rt->dst.header_len : 0;
 	length += exthdrlen;
 	transhdrlen += exthdrlen;
-	mtu = inet->cork.fragsize;
+	mtu = cork->fragsize;
 
 	hh_len = LL_RESERVED_SPACE(rt->dst.dev);

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
