From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Wed, 16 Jun 2004 23:37:31 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616193731.GB29781@ms2.inr.ac.ru>
References: <20040613121514.6b3c1c8a.davem@redhat.com> <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au> <20040613234142.GA32329@gondor.apana.org.au> <20040613183622.3a814506.davem@redhat.com> <20040614015013.GA11048@gondor.apana.org.au> <20040613210725.70dbd016.davem@redhat.com> <20040614042216.GA28669@gondor.apana.org.au> <20040614102858.GA12343@gondor.apana.org.au> <20040614124402.GA28519@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, schwab@suse.de, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040614124402.GA28519@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Alexey, if I've missed any subtle piece of logic there, please
> scream :)

The "logic" behind the check ("logic" is double quoted because
of that comment)  with dst_discard_out was to make
release only on the second attempt to unregister. In the past
unregister event used to be rebroadcast periodically until the unregister
finally succeeds. Now logic is different, so this check really
does not make sense.

Anyway, the comment remains damn true and the place is still
bug. It makes sense to think about waiting for at least one quiescent
state after detaching the stale device from dst and real dev_put() it.
Reference to RCU is not occasional, the job looks natural for it.

Alexey
