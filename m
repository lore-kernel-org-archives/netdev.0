From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sun, 6 Feb 2005 22:32:39 -0800
Message-ID: <20050206223239.5dc4e325.davem@davemloft.net>
References: <20050128230327.GV31837@postel.suug.ch>
	<E1CufRB-0000zf-00@gondolin.me.apana.org.au>
	<20050128234828.GA24868@yakov.inr.ac.ru>
	<20050129002128.GX31837@postel.suug.ch>
	<20050129002701.GY31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050129002701.GY31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 29 Jan 2005 01:27:01 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * Thomas Graf <20050129002128.GX31837@postel.suug.ch> 2005-01-29 01:21
> > --- linux-2.6.11-rc2-bk4.orig/net/ipv4/tcp_input.c	2005-01-26 18:19:42.000000000 +0100
> > +++ linux-2.6.11-rc2-bk4/net/ipv4/tcp_input.c	2005-01-29 01:12:30.000000000 +0100
> > @@ -3760,8 +3760,7 @@
> >  	while (before(start, end)) {
> >  		struct sk_buff *nskb;
> >  		int header = skb_headroom(skb);
> > -		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
> > -			    sizeof(struct skb_shared_info) - header - 31)&~15;
> > +		int copy = SKB_MAX_ORDER(header + 31, 0);
> >  
> >  		/* Too big header? This can happen with IPv6. */
> >  		if (copy < 0)
> 
> Sorry, this is incomplete, we should refetch copy via (skb->end - skb->head) after
> allocating it.  I have to think some more about this first. ;-)

I don't understand, if we alloc_skb(copy) we are guarenteed to have
"copy" bytes available in the SKB data area.

This transformation to SKB_MAX_ORDER() (with the "+ 31" removed as
per Alexey's reply), seems perfectly fine to me.

Isn't it?
