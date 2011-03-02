From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 2 Mar 2011 15:31:23 +0800
Message-ID: <20110302073123.GA18443@gondor.apana.org.au>
References: <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301115305.GA6984@gondor.apana.org.au> <1298984609.3284.98.camel@edumazet-laptop> <20110301131823.GB8028@gondor.apana.org.au> <1298997084.3284.119.camel@edumazet-laptop> <20110302002353.GA15009@gondor.apana.org.au> <1299031203.2930.26.camel@edumazet-laptop> <20110302023920.GA16072@gondor.apana.org.au> <AANLkTim0+7mTYrQF3mttUW+JqOmvTyMoDXOdeCX_SSdp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51209 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab1CBHbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 02:31:38 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTim0+7mTYrQF3mttUW+JqOmvTyMoDXOdeCX_SSdp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 11:12:29PM -0800, Tom Herbert wrote:
>
> Probably need to set skb->ooo_okay (for UDP etc.) also so that XPS
> will change queues.

Hmm, not quite.  We still want to maintain packet ordering from
the same CPU.  That is, if I do two sendmsg calls from the same
CPU, they should go into the same queue in that order.

So this shouldn't just be a knob that says whether we can pick
queues at random.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
