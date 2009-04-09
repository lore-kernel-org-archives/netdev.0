From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Software receive packet steering
Date: Thu, 09 Apr 2009 19:23:32 +0100
Message-ID: <1239301412.3264.24.camel@achroite>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
	 <20090408160948.2257d311@s6510>
	 <20090408.161515.40986410.davem@davemloft.net>
	 <65634d660904090943lf273d9cg92be105acef3e6af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35945 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932962AbZDISXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 14:23:38 -0400
In-Reply-To: <65634d660904090943lf273d9cg92be105acef3e6af@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-09 at 09:43 -0700, Tom Herbert wrote:
> >>> -extern int          netif_receive_skb(struct sk_buff *skb);
> >>> +extern int            __netif_receive_skb(struct sk_buff *skb);
> >>> +
> >>> +static inline int netif_receive_skb(struct sk_buff *skb)
> >>> +{
> >>> +#ifdef CONFIG_NET_SOFTRPS
> >>> +    return netif_rx(skb);
> >>> +#else
> >>> +    return __netif_receive_skb(skb);
> >>> +#endif
> >>> +}
> >>
> >> Ugh, this forces all devices receiving back into a single backlog
> >> queue.
> >
> > Yes, it basically turns off NAPI.
> >
> 
> NAPI is still useful, but it does take a higher packet load before
> polling kicks in.  I believe this is similarly true for HW multi
> queue, and could actually be worse depending on the number of queues
> traffic is being split across (in my bnx2x experiment 16 core AMD with
> 16 queues, I was seeing around 300K interrupts per second, no benefit
> from NAPI).
[...]

Have you tried using fewer than 16 queues?  We found using every core in
a multi-core package to be a waste of cycles.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

