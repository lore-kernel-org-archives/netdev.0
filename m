From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Thu, 7 Apr 2005 07:29:07 +1000
Message-ID: <20050406212906.GA24775@gondor.apana.org.au>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au> <42540CF3.7070501@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike Christie <michaelc@cs.wisc.edu>
Content-Disposition: inline
In-Reply-To: <42540CF3.7070501@cs.wisc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2005 at 09:23:15AM -0700, Mike Christie wrote:
> 
> It is due to where it is being used. open-iscsi uses netlink
> sockets for communication in a block (scsi specificically)
> driver that has pushed much of its code to usersapce. Forcing
> open-iscsi to use GFP_KERNEL causes a couple of problems. The
> worst would be where a GFP_KERNEL allocation causes a write,
> and that write is to an iscsi disk that open-iscsi is managing.
> The write could then hit the same code path and cause another
> GFP_KERNEL allocation and we could loop like that until the
> system locks up.

In that case it's not enough to just use sk_allocation here.
You'll need a way to actually set it to GFP_ATOMIC.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
