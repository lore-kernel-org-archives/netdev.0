From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 10:34:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814003428.GA17760@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040813151923.3311b4f0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 13, 2004 at 03:19:23PM -0700, David S. Miller wrote:
> On Sat, 14 Aug 2004 07:56:02 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Now had you put this barrier between the reading of ip_ptr and
> > the checking of in_dev->dead, then the race would've been closed.

Actually even that won't close the race so the barrier is completely
unnecessary.

> > But I still prefer to move the work into inetdev_destroy.
> 
> Ok I see now.  I've added your patch, it seems correct.

Thanks.  I presume you've reversed the previous patch as well?

BTW, it looks like you can remove inetdev_lock altogether.  All its
users already assume that they don't race against each other by
taking the rtnl lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
