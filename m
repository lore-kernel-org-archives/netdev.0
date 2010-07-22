From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvtap: Limit packet queue length
Date: Fri, 23 Jul 2010 00:07:31 +0800
Message-ID: <20100722160731.GA30723@gondor.apana.org.au>
References: <20100722064157.GA25913@gondor.apana.org.au> <1279814398.3211.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>, Mark Wagner <mwagner@redhat.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58998 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936Ab0GVQHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 12:07:37 -0400
Content-Disposition: inline
In-Reply-To: <1279814398.3211.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 08:59:58AM -0700, Shirley Ma wrote:
> On Thu, 2010-07-22 at 14:41 +0800, Herbert Xu wrote:
> >  {
> >         struct macvtap_queue *q = macvtap_get_queue(dev, skb);
> >         if (!q)
> > -               return -ENOLINK;
> > +               goto drop;
> > +
> > +       if (skb_queue_len(&q->sk.sk_receive_queue) >=
> > dev->tx_queue_len)
> > +               goto drop;
> > 
> 
> Do we need to orphan skb here, just like tun?

We could, but that is orthogonal to the problem at hand so feel
free to do that in another patch.

> >         skb_queue_tail(&q->sk.sk_receive_queue, skb);
> >         wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN |
> > POLLRDNORM | POLLRDBAND);
> > -       return 0;
> > +       return NET_RX_SUCCESS;
> > +
> > +drop:
> 
> Do we need to increase dropped++ counter here to let user know there are
> packets dropped?

The caller is supposed to handle this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
