From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Sun, 15 Nov 2015 11:32:10 +0800
Message-ID: <20151115033210.GA21848@gondor.apana.org.au>
References: <20151115012032.GA21282@gondor.apana.org.au>
 <1447557701.22599.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47256 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbKODcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 22:32:12 -0500
Content-Disposition: inline
In-Reply-To: <1447557701.22599.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 14, 2015 at 07:21:41PM -0800, Eric Dumazet wrote:
>
> This patch makes sure sk_ack_backlog is written before sk_state is set
> to TCP_LISTEN, otherwise one could see a '0' listener backlog.
> 
> We had a spurious kernel log for a similar issue that was solved in
> commit f985c65c908f6b26c30019a83dc5ea295f5fcf62
> ("tcp: avoid spurious SYN flood detection at listen() time")
> 
> Sure, we can live with a spurious log, but experience showed that taking
> care of this early could avoid lot of hassle, say in 12 months when
> people start using linux-4.4 

Oh I have no problems whatsoever with adding barriers where they
are needed, such as in this particular spot.  What I do have an
issue with though is the fact that your patch in its current form
may give future TCP developers a false sense of security.

I know that you as the person who added these helpers know exactly
what they do and don't do.  But the next guy who comes along may
not have that complete understanding and they may think that these
helpers give them the right to do things locklessly.

So personally I'd prefer explicit barriers in the spots where they
are needed with detailed comments as opposed to these helpers which
appear to offer guarrantees that they can't really give.

Or perhaps give these helpers names that make people think twice,
e.g., tcp_load_state_unsafe.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
