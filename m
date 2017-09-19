From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] net: avoid a full fib lookup when rp_filter is
 disabled.
Date: Tue, 19 Sep 2017 14:46:41 +0200
Message-ID: <1505825201.2646.39.camel@redhat.com>
References: <1967ebaa528c626ebd9682e927fd33770a396a0a.1505817863.git.pabeni@redhat.com>
         <1505822433.29839.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12895 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751411AbdISMqn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 08:46:43 -0400
In-Reply-To: <1505822433.29839.44.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, 2017-09-19 at 05:00 -0700, Eric Dumazet wrote:
> On Tue, 2017-09-19 at 12:46 +0200, Paolo Abeni wrote:
> ..
> 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> > +/* called under RCU lock */
> > +struct in_ifaddr *inet_lookup_ifaddr_rcu(struct net *net, __be32 addr)
> > +{
> > +	u32 hash = inet_addr_hash(net, addr);
> > +	struct in_ifaddr *ifa;
> > +
> > +	hlist_for_each_entry_rcu(ifa, &inet_addr_lst[hash], hash)
> > +		if (ifa->ifa_local == addr &&
> > +		    net_eq(dev_net(ifa->ifa_dev->dev), net))
> > +			return ifa;
> > +
> > +	return NULL;
> > +}
> > +

Thank you for reviewing this!

> Any particular reason you do not use this helper to replace the lookup
> in __ip_dev_find() ?

uh, I just missed that opportunity. I'll send a v2, thanks!

Paolo
