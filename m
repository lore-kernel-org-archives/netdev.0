From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 14:15:25 -0700 (PDT)
Message-ID: <20050510.141525.23014027.davem@davemloft.net>
References: <1115743966.8570.26.camel@rh4>
	<20050510.121214.39158393.davem@davemloft.net>
	<1115754210.8570.63.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mperaya@alcazaba.unex.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1115754210.8570.63.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 12:43:30 -0700

> There is clear benefit in doing longer bursts when the bridge can handle
> it.

No question.

> It was explained to me that on some risc systems such as ppc, and
> assuming the bridge can handle long DMA bursts, it is still best to
> disconnect at page or cache line boundaries. The reason is that if the
> burst stops at any arbitrary address, the bridge has to refetch the
> cache line and often the mapping information. Disconnecting at multiple
> cache lines is to address this problem while still achieving longer DMA
> bursts.

Ok, I see.

It is aparently causing some kind of trouble for this person
on his PPC system though.  I think we should back down to
single-cacheline on non-X86 until we really can get a grasp
on what machines it is both:

1) beneficial
2) does not corrupt data

And that is what my patch aims to do for the time being.

Even once the problem case is resolved, that setting should
be bracketed in some test that specifically only enables
the longer bursting where it actually helps not hinders.
It definitely should not be done unconditonally for all
non-X86 systems.
