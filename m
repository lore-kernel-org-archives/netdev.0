From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Thu, 7 Apr 2005 08:04:17 +1000
Message-ID: <20050406220417.GA4443@gondor.apana.org.au>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au> <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au> <1112823442.16753.68.camel@beastie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112823442.16753.68.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2005 at 02:37:21PM -0700, Dmitry Yusupov wrote:
>
> > In that case it's not enough to just use sk_allocation here.
> > You'll need a way to actually set it to GFP_ATOMIC.
> 
> That's why in my patch I provided NETLINK_UESTABLISHED event. It is a
> right way and time to set sk->sk_allocation to GFP_ATOMIC for newly
> established netlink connection. imho.

Right.  In that case I think you're going about this the wrong way.
It's unmanageable to have some external kernel module fiddle with
netlink's sk_allocation upon the receipt of a notification.

If you really want to do this, do it as a setsockopt.  It's the owner
of the socket that wants the GFP_ATOMIC, not anybody else.

However, I'd like to know more about how open-iscsi uses this.  In
particular, what are these messages and what do you do when the
GFP_ATOMIC alloc_skb fails?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
