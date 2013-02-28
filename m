From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next] generalize VXLAN forwarding tables
Date: Thu, 28 Feb 2013 17:55:27 -0500
Message-ID: <OF02E8A5C2.4BBAEF8D-ON85257B20.007D6D06-85257B20.007DED1A@us.ibm.com>
References: <201302281924.r1SJN7u5024149@lab1.dls> <1362090475.15793.51.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42160 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755255Ab3B1W5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 17:57:45 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 28 Feb 2013 15:57:45 -0700
In-Reply-To: <1362090475.15793.51.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 02/28/2013 05:27:55 PM:

> From: Eric Dumazet <eric.dumazet@gmail.com>

> On Thu, 2013-02-28 at 14:23 -0500, David L Stevens wrote:
> 
> > +   /* if there are multiple destinations, send copies */
> > +   for (rdst = rdst0->remote_next; rdst; rdst = rdst->remote_next) {
> > +      struct sk_buff *skb1;
> > +
> > +      skb1 = skb_clone(skb, GFP_ATOMIC);
> > +      rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> > +      if (rc == NETDEV_TX_OK)
> > +         rc = rc1;
> > +   }
> > +
> > +   rc1 = vxlan_xmit_one(skb, dev, rdst0, did_rsc);
> > +   if (rc == NETDEV_TX_OK)
> > +      rc = rc1;
> > +   return rc;
> > +}
> 
> 
> It looks like vxlan_xmit_one() will overwrite header
> 
> So skb_clone() is probably not what you wanted ?

We're only prepending encapsulation headers, and we
do skb_cow_head() for each of those in vxlan_xmit_one().
This skb should be just the original , unencapsulated
packet which is identical in all copies.

                                                +-DLS
