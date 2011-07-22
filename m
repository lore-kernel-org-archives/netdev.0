From: Florian Westphal <fw@strlen.de>
Subject: Re: icmp_route_lookup returns wrong source address information
Date: Fri, 22 Jul 2011 16:15:31 +0200
Message-ID: <20110722141531.GA12328@Chamillionaire.breakpoint.cc>
References: <20110720192258.GA21528@Chamillionaire.breakpoint.cc>
 <20110722.062302.350752564450519025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:37532 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754543Ab1GVOPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 10:15:33 -0400
Content-Disposition: inline
In-Reply-To: <20110722.062302.350752564450519025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Wed, 20 Jul 2011 21:22:58 +0200
> 
> > Problem is that xfrm_decode_session_reverse() may rebuild fl4 from scratch.
> > 
> > In my setup, "goto relookup_failed" will be hit a bit later on, and fl4->saddr will
> > be set to iph->daddr...
> 
> Indeed, we can't use this new fl4 until we commit to using 'rt2'.
> 
> Please give this patch a try:
> 
> --------------------
> icmp: Fix regression in nexthop resolution during replies.
> 
> icmp_route_lookup() uses the wrong flow parameters if the reverse
> session route lookup isn't used.
> 
> So do not commit to the re-decoded flow until we actually make a
> final decision to use a real route saved in 'rt2'.

Thanks, traceroute shows the expected 1st hop again
with your patch applied.
