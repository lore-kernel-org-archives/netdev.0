From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 16:53:45 -0800
Message-ID: <20050315165345.735573de.davem@davemloft.net>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>
	<423764A3.8030201@pobox.com>
	<20050315150809.579c5e85.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, christoph@graphe.net,
        nirajk@calsoftinc.com, christoph@lameter.com, Shai@Scalex86.org
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050315150809.579c5e85.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 15:08:09 -0800
Andrew Morton <akpm@osdl.org> wrote:

> Jeff Garzik <jgarzik@pobox.com> wrote:
> >
> > > -	dev->last_rx = jiffies;
> > > -
> > >  	lb_stats = &per_cpu(loopback_stats, get_cpu());
> > >  	lb_stats->rx_bytes += skb->len;
> > >  	lb_stats->tx_bytes += skb->len;
> > 
> > I disagree.  loopback.c is doing precisely what it should be doing.
> 
> Nothing actually seems to use last_rx?

For one thing bonding load balancing uses it.

You can argue that bonding of loopback devices is silly.
But there are other things one might be able to do with
last_rx and the fact that every driver faithfully sets
it means that it's a reliable metric to use without
special cases.

These loopback driver SMP optimizations are starting to really
driver me crazy.
