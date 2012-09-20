From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:51:45 +0200
Message-ID: <1348145505.4161.32.camel@jlt4.sipsolutions.net>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
	 (sfid-20120920_144505_999408_BB063E95) <1348145269.4161.28.camel@jlt4.sipsolutions.net>
	 (sfid-20120920_144723_081920_00B84F43)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: artem.bityutskiy@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:48736 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab2ITMvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 08:51:09 -0400
In-Reply-To: <1348145269.4161.28.camel@jlt4.sipsolutions.net> (sfid-20120920_144723_081920_00B84F43)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 14:47 +0200, Johannes Berg wrote:

> >                 if (skb) {
> >                         /* deliver to local stack */
> > -                       skb->protocol = eth_type_trans(skb, dev);
> > -                       memset(skb->cb, 0, sizeof(skb->cb));
> > -                       netif_receive_skb(skb);
> > +                       if (pskb_may_pull(skb, sizeof(struct ethhdr))) {
> > +                               skb->protocol = eth_type_trans(skb, dev);
> > +                               memset(skb->cb, 0, sizeof(skb->cb));
> > +                               netif_receive_skb(skb);
> > +                       } else {
> > +                               kfree_skb(skb);
> > +                       }
> >                 }
> >         }
> 
> Yeah I was looking at the same code just now. However, we had actually
> inserted the skb_linearize() *after* eth_type_trans(), so I'm confused.

Ok actually, by the time we get here the ethernet header must be in the
skb head because we construct it from the 802.11 and llc/snap header.

johannes
