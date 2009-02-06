From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: copyless virtio net thoughts?
Date: Fri, 6 Feb 2009 20:19:04 +1100
Message-ID: <20090206091904.GA6645@gondor.apana.org.au>
References: <20090205020732.GA27684@sequoia.sous-sol.org> <498ADD73.3060906@redhat.com> <20090206054054.GA4824@gondor.apana.org.au> <498BF8ED.8090208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, Arnd Bergmann <arnd@arndb.de>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <498BF8ED.8090208@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 06, 2009 at 10:46:37AM +0200, Avi Kivity wrote:
>
> The guest's block layer is copyless.  The host block layer is -><- this  
> far from being copyless -- all we need is preadv()/pwritev() or to  
> replace our thread pool implementation in qemu with linux-aio.   
> Everything else is copyless.
>
> Since we are actively working on this, expect this limitation to  
> disappear soon.

Great, when that happens I'll promise to revisit zero-copy transmit :)

> I support this, but it should be in addition to copylessness, not on its  
> own.

I was talking about it in the context of zero-copy receive, where
you mentioned that the virtio/kvm copy may not occur on the CPU of
the guest's copy.

My point is that using multiqueue you can avoid this change of CPU.

But yeah I think zero-copy receive is much more useful than zero-
copy transmit at the moment.  Although I'd prefer to wait for
you guys to finish the block layer work before contemplating
pushing the copy on receive into the guest :)

> - many guests will not support multiqueue

Well, these guests will suck both on baremetal and in virtualisation,
big deal :) Multiqueue at 10GbE speeds and above is simply not an
optional feature.

> - for some threaded workloads, you cannot predict where the final read()  
> will come from; this renders multiqueue ineffective for keeping cache  
> locality
>
> - usually you want virtio to transfer large amounts of data; but if you  
> want your copies to be cache-hot, you need to limit transfers to half  
> the cache size (a quarter if hyperthreading); this limits virtio  
> effectiveness

Agreed on both counts.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
