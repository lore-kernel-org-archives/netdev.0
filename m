From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Mon, 7 Feb 2005 14:28:30 +0100
Message-ID: <20050207132830.GZ31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au> <20050128234828.GA24868@yakov.inr.ac.ru> <20050129002128.GX31837@postel.suug.ch> <20050129002701.GY31837@postel.suug.ch> <20050206223239.5dc4e325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050206223239.5dc4e325.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > >  		struct sk_buff *nskb;
> > >  		int header = skb_headroom(skb);
> > > -		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
> > > -			    sizeof(struct skb_shared_info) - header - 31)&~15;
> > > +		int copy = SKB_MAX_ORDER(header + 31, 0);
> > >  
> > >  		/* Too big header? This can happen with IPv6. */
> > >  		if (copy < 0)
> > 
> > Sorry, this is incomplete, we should refetch copy via (skb->end - skb->head) after
> > allocating it.  I have to think some more about this first. ;-)
> 
> I don't understand, if we alloc_skb(copy) we are guarenteed to have
> "copy" bytes available in the SKB data area.

Yes but don't we waste space in the headroom of the new skb iff the
headroom of the original skb is no aligned to SKB_DATA_ALIGN?

I'll post a new patch without the anyway though.
