From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Fri, 18 Oct 2013 13:10:41 +0200
Message-ID: <20131018111041.GA10964@localhost>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
 <20131017112857.GA11318@localhost>
 <20131017113735.GB2699@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45508 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753070Ab3JRLKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 07:10:49 -0400
Content-Disposition: inline
In-Reply-To: <20131017113735.GB2699@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
> On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
> > Hi,
> > > +
> > > +/**
> > > + * br_netfilter_skb_free - clean the NF bridge data in an skb
> > > + * @skb: the skb which the data to free belongs to
> > > + */
> > > +void br_netfilter_skb_free(struct sk_buff *skb)
> > > +{
> > > +	nf_bridge_put(skb->nf_bridge);
> > > +	skb->nf_bridge = NULL;
> > > +}
> > 
> > This should be nf_reset.
> 
> You think I should directly use nf_reset instead of this function?
> 
> I see that nf_reset() cleans up the conntrack part too: does it also become
> useless once the packet exits the bridge interface?

The conntrack should not attached if it's forwarded to another netif,
see dev_forward_skb.

But I'm not sure what scenario you're trying to handle with this
change, if you could please elaborate.

Perhaps your fix is more conservative to avoid breaking strange setups
that have been relying on this behaviour. I know of people deploying
strange configurations using netfilter bridge.
