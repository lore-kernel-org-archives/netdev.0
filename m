From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Thu, 17 Jun 2004 18:17:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617081722.GA8559@gondor.apana.org.au>
References: <20040613183622.3a814506.davem@redhat.com> <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au> <20040614102858.GA12343@gondor.apana.org.au> <20040614124402.GA28519@gondor.apana.org.au> <20040616193731.GB29781@ms2.inr.ac.ru> <20040616130950.6aadde3c.davem@redhat.com> <20040616203748.GA30675@ms2.inr.ac.ru> <20040616134711.499209c9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, schwab@suse.de,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040616134711.499209c9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2004 at 01:47:11PM -0700, David S. Miller wrote:
> On Thu, 17 Jun 2004 00:37:48 +0400
> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> > Sort of. I think it should happen after killing reference to dst->dev:
>  ...
> > but before dropping reference to dev:
>  ...
> > So, I think it should look like:
> > 
> > 		dst->dev = &loopback_dev;
> > 		dev_hold(&loopback_dev);
> > +		synchronize_kernel();
> > 		dev_put(dev);
> 
> Perfect, that's what I put into my tree then, plus some comment.

Yes we definitely want this call.  But wouldn't it be better to do one
call at the top level, say at the end of netdev_wait_allrefs?

Otherwise we may end up with lots of synchronize_kernel() calls
scattered in each individual event handler.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
