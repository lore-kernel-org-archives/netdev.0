From: "David S. Miller" <davem@davemloft.net>
Subject: Re: oops in ip_rcv
Date: Thu, 5 May 2005 11:26:24 -0700
Message-ID: <20050505112624.3ffd7f3d.davem@davemloft.net>
References: <20050505101542.GB7916@krispykreme>
	<E1DTeis-0005gu-00@gondolin.me.apana.org.au>
	<20050505130904.GA16593@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050505130904.GA16593@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 May 2005 23:09:04 +1000
Anton Blanchard <anton@samba.org> wrote:

>  
> > Any idea why you'd be receiving packets this early?
> 
> Not sure, although PCI has already been probed and tcp_init is called
> with interrupts on. Any reason we cant take a packet at this point?
> 
> Im guessing its calling this:
> 
>         IP_INC_STATS_BH(IPSTATS_MIB_INRECEIVES);
> 
> Which we dont initialise until later on in init_ipv4_mibs.

Can you test out putting the init_ipv4_mibs() call right before
the comment:

	/*
	 *	Add all the base protocols.
	 */

If it fixes things for you I'll put that upstream.

Thanks.

I still would really like to know how you are getting packets
at all that early.  Even if PCI is initialized, no interfaces
should be marked up at _all_.
