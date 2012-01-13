From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 07:22:56 +0100
Message-ID: <20120113062256.GC12501@secunet.com>
References: <20120111000040.GA3801@p183.telecom.by>
 <20120111003611.GA12257@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54413 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab2AMGW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 01:22:58 -0500
Content-Disposition: inline
In-Reply-To: <20120111003611.GA12257@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 11:36:11AM +1100, Herbert Xu wrote:
> On Wed, Jan 11, 2012 at 03:00:40AM +0300, Alexey Dobriyan wrote:
> > commit f9e2bca6c22d75a289a349f869701214d63b5060
> > aka "crypto: sha512 - Move message schedule W[80] to static percpu area"
> > created global message schedule area.
> > 
> > If sha512_update will ever be entered twice, hilarity ensures.
> 
> Hmm, do you know why this happens? On the face of it this shouldn't
> be possible as preemption is disabled.
> 

I did not try to reproduce, but this looks like a race of the 'local out'
and the receive packet path. On 'lokal out' bottom halves are enabled,
so could be interrupted by the NET_RX_SOFTIRQ while doing a sha512_update.
The NET_RX_SOFTIRQ could invoke sha512_update too, that would corrupt the
hash value. My guess could be checked easily by disabling the bottom halves
before the percpu value is fetched.
