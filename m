From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Wed, 06 Apr 2005 14:37:21 -0700
Message-ID: <1112823442.16753.68.camel@beastie>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
	 <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050406212906.GA24775@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-04-07 at 07:29 +1000, Herbert Xu wrote:
> On Wed, Apr 06, 2005 at 09:23:15AM -0700, Mike Christie wrote:
> > 
> > It is due to where it is being used. open-iscsi uses netlink
> > sockets for communication in a block (scsi specificically)
> > driver that has pushed much of its code to usersapce. Forcing
> > open-iscsi to use GFP_KERNEL causes a couple of problems. The
> > worst would be where a GFP_KERNEL allocation causes a write,
> > and that write is to an iscsi disk that open-iscsi is managing.
> > The write could then hit the same code path and cause another
> > GFP_KERNEL allocation and we could loop like that until the
> > system locks up.
> 
> In that case it's not enough to just use sk_allocation here.
> You'll need a way to actually set it to GFP_ATOMIC.

correct.

That's why in my patch I provided NETLINK_UESTABLISHED event. It is a
right way and time to set sk->sk_allocation to GFP_ATOMIC for newly
established netlink connection. imho.
