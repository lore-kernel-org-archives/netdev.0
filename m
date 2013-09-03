From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour
 discovery messages
Date: Tue, 3 Sep 2013 13:11:17 +0100
Message-ID: <20130903121117.GA4166@casper.infradead.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
 <20130903115635.GA21729@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47251 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab3ICMcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 08:32:54 -0400
Content-Disposition: inline
In-Reply-To: <20130903115635.GA21729@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/13 at 01:56pm, Hannes Frederic Sowa wrote:
> Hi!
> 
> On Tue, Sep 03, 2013 at 01:37:01PM +0200, Thomas Graf wrote:
> > @@ -389,6 +386,11 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
> >  	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
> >  	skb_reset_transport_header(skb);
> >  
> > +	/* Manually assign socket ownership as we avoid calling
> > +	 * sock_alloc_send_pskb() to bypass wmem buffer limits
> > +	 */
> > +	skb_set_owner_w(skb, sk);
> > +
> >  	return skb;
> >  }
> 
> Do you know why this is needed? From the report it seemed to me that we might
> have a deadlock on idev->lock and I couldn't find the culprit.
> 
> When I tested your change on x86_64 I did not experience this.

I also didn't see any problems running v1 of the patch which
is confusing as the IPv6 output path assumes a socket reference
in various places as Dave pointed out correctly.

I don't see why the problem would be limited to ARM.

> Maybe someone with arm could try this patch with CONFIG_PROVE_LOCKING?

I would certainly welcome that.
