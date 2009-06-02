From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 11:35:03 +0200
Message-ID: <4A24F247.2040406@dev.6wind.com>
References: <4A23F027.3060907@dev.6wind.com>	 <20090601161917.GA29745@Chamillionaire.breakpoint.cc>	 <4A240681.2010300@6wind.com> <4A242161.3010609@cosmosbay.com>	 <4A242418.1090804@hp.com> <1243907646.15854.16.camel@merlyn>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:4812 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbZFBKDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 06:03:30 -0400
In-Reply-To: <1243907646.15854.16.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Dykstra wrote:
> On Mon, 2009-06-01 at 14:55 -0400, Brian Haley wrote: 
>> 'ping6 -t 0 host' does work however.  The problem I see is that if you ping a system,
>> if it's a host it will respond, if it's a router it won't - the RFCs don't
>> explicitly state the host should drop the packet.  
> 
> There are two cases--an echo request to an address assigned to a
> router's interface, and to an address _beyond_ the router on another
> link.
> 
> Any given interface on a router can have forwarding dynamically enabled
> or disabled.  I don't remember prescribed echo request or hop limit
> behavior changing depending on the forwarding enable, so it seems that
> if you ping an address assigned to a router's interface, the router is
> expected to follow the (apparently unwritten) host rules.  
Good point.

> 
> Echo requests forwarded by a router should obviously have the hop limit
> decremented and checked.
> 
>> I don't know if that difference
>> in behavior is desired.  Do we know how any other OSes behave?
> 
> FWIW, the random BSD flavors I have on hand all check hop limit when
> forwarding, but not when processing local ingress traffic.
> 
> Also FWIW, as I remember, the TAHI tests only check hop limit behavior
> on forwarded traffic.
Right.

> 
> Nicolas, what's driving your patch?  Are you trying to align slow path
> behavior with one of the 6WIND fast path implementations?
No. I'm just checking RFC conformance ;-)


Nicolas

> 
>   --  John
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
