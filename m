From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [Bridge] [PATCH net-next v2 2/2] net: bridge: add per-port
 multicast flood flag
Date: Wed, 31 Aug 2016 19:28:12 +0200
Message-ID: <20160831172812.GJ4883@otheros>
References: <1472570588-32503-1-git-send-email-nikolay@cumulusnetworks.com>
 <1472570588-32503-3-git-send-email-nikolay@cumulusnetworks.com>
 <20160831013726.GD4883@otheros>
 <7d1fc865-f092-5d9d-8f4c-f19aeac914c0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.aperture-lab.de ([138.201.29.205]:60411 "EHLO
        mail.aperture-lab.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935929AbcHaR2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:28:20 -0400
Content-Disposition: inline
In-Reply-To: <7d1fc865-f092-5d9d-8f4c-f19aeac914c0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 08:02:22AM +0200, Nikolay Aleksandrov wrote:
> On 31/08/16 03:37, Linus Lüssing wrote:
> > On Tue, Aug 30, 2016 at 05:23:08PM +0200, Nikolay Aleksandrov via Bridge wrote:
> >> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> >> index 1da3221845f1..ed0dd3340084 100644
> >> --- a/net/bridge/br_if.c
> >> +++ b/net/bridge/br_if.c
> >> @@ -362,7 +362,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
> >>  	p->path_cost = port_cost(dev);
> >>  	p->priority = 0x8000 >> BR_PORT_BITS;
> >>  	p->port_no = index;
> >> -	p->flags = BR_LEARNING | BR_FLOOD;
> >> +	p->flags = BR_LEARNING | BR_FLOOD | BR_MCAST_FLOOD;
> > 
> > I'm discontent with this new flag becoming the default.
> > 
> > Could you elaborate a little more on your use-case, when/why do
> > you want/need this flag?
> > 
> 
> The use case is the current default behaviour if we don't make this flag on by default
> then we'll change user-visible default behaviour. Right now we flood unregistered mcast
> traffic by default (if there's no querier and router port, which continues to function
> as before). Also we have the port flags equal to BR_AUTO_MASK by default.

Ok, you're right, the way you implemented it doesn't
change the default behaviour (ignoring the BR_AUTO_MASK change you
removed in v3).

I guess the "similar to the unknown unicast flood flag" confused
me a little and I was afraid that the "flood if there is no
listener / MDB entry" behaviour, which was removed some years ago,
would be reintroduced. (but yeah, looking at the code more
closely, it doesn't do that)

Thanks for the clarification!

Regards, Linus
