From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] net: neighbour: use source address of last enqueued packet for solicitation
Date: Fri, 13 Sep 2013 00:20:17 +0200
Message-ID: <20130912222017.GD2101@order.stressinduktion.org>
References: <20130908193031.GC21070@order.stressinduktion.org> <alpine.LFD.2.00.1309092208460.1655@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54433 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab3ILWUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 18:20:18 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1309092208460.1655@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 09, 2013 at 11:17:45PM +0300, Julian Anastasov wrote:
> 	arp_queue has packets only in NUD_INCOMPLETE state 
> (mcast_solicit=3 secs by default). And __neigh_event_send()
> now can keep many packets, 64KB from recent changes. So the
> 1st place is not guaranteed but now it is more difficult
> to kick the first packet compared to the old limit of just
> 3 packets.
> 
> 	The change can give chance for 2nd and 3th
> probe if the 1st probe is not replied, so it should be
> better to apply it:
> 
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Thanks for the review. I resend the patch as soon as net-next opens.

> 
> 	Still, I think such problems should be addressed
> with conf/{DEV,all}/arp_announce=1 or 2.

*nod*

I use this knob if I have such problems. But this patch improves
connectivity in the default configuration and we actually don't care much
about the source address in either ipv4 or ipv6. So it seemed legitimate
and simple to me.

Greetings,

  Hannes
