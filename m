From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sparc oops in ip_fast_csum
Date: Sun, 6 Jan 2008 12:03:59 +1100
Message-ID: <20080106010358.GA2991@gondor.apana.org.au>
References: <E1JBJHA-0000hy-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0801060156410.14194@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>, m.kozlowski@tuxland.pl,
	davem@davemloft.net, sparclinux@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2964 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754146AbYAFBEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 20:04:13 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801060156410.14194@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 06, 2008 at 01:57:13AM +0100, Jan Engelhardt wrote:
>
> >@@ -304,7 +305,8 @@ static int raw_send_hdrinc(struct sock *sk, void *from, size_t length,
> > 		goto error_fault;
> > 
> > 	/* We don't modify invalid header */
> >-	if (length >= sizeof(*iph) && iph->ihl * 4U <= length) {
> >+	iphlen = iph->ihl * 4;
> >+	if (iphlen >= sizeof(*iph) && iphlen <= length) {
> 
> Humm, this could use ip_hdrlen(skb) :-)

That would not necessarily be an improvement since we'd have to reload
the values from skb.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
