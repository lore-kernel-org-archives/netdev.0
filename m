From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 15:55:05 +0300
Message-ID: <20081217125505.GA8379@ms2.inr.ac.ru>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:56155 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752115AbYLQNOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 08:14:19 -0500
Content-Disposition: inline
In-Reply-To: <20081217114138.GA20976@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> In other words what we do currently potentially makes urgent
> mode completely useless since it may delay the sending of the
> urgent notification indefinitely.  While the BSD behaviour would
> only break "broken" applications.

This is true.

It definitely will work with correct application (those which
use SO_OOBINLINE), and surely will kill those which treat
urg data in _default_ __BSD__("BSD behaviour", you say, huh:-))
way and withdraw octet at urgent pointer. 

Probably, netbsd/openbsd have some another quirk to work this around.
I do not see how, though.

I decided that this is a fatal conflict, which can be solved cleanly
only in a painful way like you suggested. Current approach delaying
URG is the way which does not spoil any data, breaking only in the
case of aborts.

If you are serious about this, also it would be a good idea
to make SO_OOBINLINE default option. Consider this. At least this
will allow to trap applications which will corrupt data stream
earlier.

Alexey
