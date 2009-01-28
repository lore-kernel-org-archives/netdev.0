From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
	hashing.
Date: Wed, 28 Jan 2009 19:53:58 +1100
Message-ID: <20090128085358.GA15593@gondor.apana.org.au>
References: <20090127.164027.245779962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40805 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751930AbZA1IyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 03:54:01 -0500
Content-Disposition: inline
In-Reply-To: <20090127.164027.245779962.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> +       if (skb_rx_queue_recorded(skb)) {
> +               u32 val = skb_get_rx_queue(skb);
> +
> +               hash = jhash_1word(val, simple_tx_hashrnd);

I'm not so sure about this added randomness.  On the one hand
I can see the benefit in being defensive about hashing, but this
does pose a problem for admins who're trying to optimse the system
by tying RX interrupts together with TX interrupts for the most
common traffic path.

For example, if you're forwarding traffic between multiqueue NICs
A and B, one would like to make it so that each queue on A goes
to a fixed queue on B where the CPU of the RX queue IRQ handler on
A is the same as the CPU of the TX queue IRQ handler on B.

This can still be done with the randomness, but it is much more
difficult.  Also if the randomness changes, we'd have to rejig
the IRQ assignment.

So can you think of a scenario where we really need this added
protection?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
