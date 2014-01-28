From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Tue, 28 Jan 2014 10:12:01 +0100
Message-ID: <20140128091201.GA25726@breakpoint.cc>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
 <1390810971-23959-2-git-send-email-fw@strlen.de>
 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140128002707.GA12308@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39148 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbaA1JMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 04:12:02 -0500
Content-Disposition: inline
In-Reply-To: <20140128002707.GA12308@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On Mon, Jan 27, 2014 at 10:22:47AM -0800, Eric Dumazet wrote:
> > On Mon, 2014-01-27 at 09:22 +0100, Florian Westphal wrote:
> > 
> > > +/* called if GSO skb needs to be fragmented on forward.  */
> > > +static int ip_forward_finish_gso(struct sk_buff *skb)
> > > +{
> > > +	netdev_features_t features = netif_skb_features(skb);
> 
> netif_skb_features uses skb->dev for determination of offloading features but
> we actually need rt->dst.dev, no?

good catch, cannot use netif_skb_features as skb->dev still
points to incoming device here...
