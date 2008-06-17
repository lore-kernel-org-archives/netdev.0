From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Killing sk->sk_callback_lock (was Re: [PATCH] net/core/sock.c remove extra wakeup)
Date: Tue, 17 Jun 2008 12:56:12 +1000
Message-ID: <20080617025612.GA8191@gondor.apana.org.au>
References: <484F43A3020000760003F543@lucius.provo.novell.com> <4856C12F020000C700039679@lucius.provo.novell.com> <4856C12F020000C700039679@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Gregory Haskins <GHaskins@novell.com>,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53959 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752315AbYFQC4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 22:56:20 -0400
Content-Disposition: inline
In-Reply-To: <4856C12F020000C700039679@lucius.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2008 at 07:38:23PM -0600, Patrick Mullaney wrote:
> 
> I don't follow but I wasn't part of the IRC discussion. :-) Please
> send me a note out of band if you would like to discuss again on IRC.
> I agree that the sk_callback_lock may be significant overhead
> (although lockstat is not showing it to be highly contended).

Lock contention doesn't matter! The worst problem with read-write
locks is cache-line bouncing.  That is, read locks will grab cache
lines from other read locks thus causing performance to go down
the drain if read locks are common (which is the only scenario
where you use read-write locks anyway).  Moral of the story is
that read-write locks are bad.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
