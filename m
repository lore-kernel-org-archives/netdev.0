From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 19/20] net: plip: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 09:06:22 -0800
Message-ID: <1388163982.30298.12.camel@joe-AO722>
References: <52BD22ED.4030302@huawei.com>
	 <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-12-27 at 07:48 -0800, Eric Dumazet wrote:
> On Fri, 2013-12-27 at 14:49 +0800, Ding Tianhong wrote:
> > Use possibly more efficient ether_addr_equal
> > to instead of memcmp.
[]
> > diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
[]
> > @@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
> >  
> >  	if(*eth->h_dest&1)
> >  	{
> > -		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
> > +		if(ether_addr_equal(eth->h_dest, dev->broadcast))
> >  			skb->pkt_type=PACKET_BROADCAST;
> >  		else
> >  			skb->pkt_type=PACKET_MULTICAST;
> 
> What about :
> 
>         if (is_multicast_ether_addr(eth->h_dest)) {
>                 if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
>                         skb->pkt_type = PACKET_BROADCAST;
>                 else
>                         skb->pkt_type = PACKET_MULTICAST;
>         }

That is better though I wonder how many systems are
still using laplink via parallel null-printer cables.

No matter, better is better.

The same optimization using ether_addr_equal_64bits
may be possible to do in other places given other
structs too.

Perhaps it's a possible spatch/coccinelle conversion,

I don't know spatch well enough to know if a
mechanism to check if structure members have other
fields that follow them in the structure or if the
structure member is an array of a minimum size.

Maybe Julia does.  (cc'd)
