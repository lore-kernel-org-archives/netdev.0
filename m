From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Killing sk->sk_callback_lock
Date: Wed, 18 Jun 2008 09:24:12 +1000
Message-ID: <20080617232412.GA16758@gondor.apana.org.au>
References: <4856C12F020000C700039679@lucius.provo.novell.com> <20080616.185328.85842051.davem@davemloft.net> <4857862A.456F.00C7.0@novell.com> <20080617.144041.38758483.davem@davemloft.net> <4857FF69.456F.00C7.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Gregory Haskins <GHaskins.WAL-1.WALTHAM@novell.com>,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50120 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759362AbYFQXYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:24:20 -0400
Content-Disposition: inline
In-Reply-To: <4857FF69.456F.00C7.0@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 04:15:46PM -0600, Patrick Mullaney wrote:
>
> Yeah, I think I mentioned that approach in my first email about this. It
> seemed like it would require adding to the socket struct so I decided to
> try to do it without touching that. I am not positive but changing the odd
> behavior of the SOCK_NOSPACE flag(mentioned in previous email) seems like
> it may be in order regardless of the approach to the extra wake up.

Fiddling with flags is just a hack.  The same socket can be used
by multiple threads, so you could have one waiting on read while
another is waiting on write.  The only real solution is to have
separate queues.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
