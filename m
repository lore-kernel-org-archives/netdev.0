From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] DM9000: fix interface hang under load
Date: Thu, 23 Aug 2007 12:16:09 +0200
Message-ID: <20070823101609.GI9315@Chamillionaire.breakpoint.cc>
References: <20070820233342.GG9315@Chamillionaire.breakpoint.cc> <20070823093749.GE12547@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:35575 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756972AbXHWKQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 06:16:26 -0400
Content-Disposition: inline
In-Reply-To: <20070823093749.GE12547@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Dooks <ben@fluff.org> wrote:
> On Tue, Aug 21, 2007 at 01:33:42AM +0200, Florian Westphal wrote:
> > @@ -700,6 +700,7 @@ dm9000_init_dm9000(struct net_device *dev)
[..]
> >  	} else {
> >  		/* Second packet */
> > -		db->tx_pkt_cnt++;
> >  		db->queue_pkt_len = skb->len;
> > +		netif_stop_queue(dev);
> >  	}

> If I read this correctly, you've moved the netif_{stop,start}_queue()
> calls so that the queue is only stopped if we have loaded 2 packets
> into the chip instead of stopping and starting each time.

Yes. For those that are not familiar with the dm9000 driver:
The queue is started again when a packet has been sent.

Thanks for taking the time to review this.

Florian
