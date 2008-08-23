From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] ip: skip IP checksum for skbs with
 CHECKSUM_UNNECESSARY set
Date: Fri, 22 Aug 2008 17:36:25 -0700 (PDT)
Message-ID: <20080822.173625.182460185.davem@davemloft.net>
References: <200808222224.32311.opurdila@ixiacom.com>
	<20080822183320.1d8fbe34@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46038
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752659AbYHWAg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 20:36:27 -0400
In-Reply-To: <20080822183320.1d8fbe34@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 22 Aug 2008 18:33:20 -0400

> On Fri, 22 Aug 2008 22:24:31 +0300
> Octavian Purdila <opurdila@ixiacom.com> wrote:
> 
> > 
> > We are working on a completely in hardware LRO implementation and this patch 
> > would simplify the hardware implementation. Is this acceptable?
> > 
> > --- a/net/ipv4/ip_input.c
> > +++ b/net/ipv4/ip_input.c
> > @@ -415,7 +415,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
> >  
> >         iph = ip_hdr(skb);
> >  
> > -       if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> > +       if (!skb_csum_unnecessary(skb) &&
> > +           unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> >                 goto inhdr_error;
> >  
> >         len = ntohs(iph->tot_len);
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> The overhead of the additional conditional might outweigh any benefit.

I don't think they want this for performance, they want to not have to
compute the IP header checksum in their HW LRO implementation, which
is just as silly :-)
