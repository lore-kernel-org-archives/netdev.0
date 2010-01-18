From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 16:24:52 -0500
Message-ID: <4B54D1A4.2020609@majjas.com>
References: <4B4E2F89.2050606@majjas.com> <20100113210908.GA3065@del.dom.local>
 <4B4E3834.3000609@majjas.com> <4B533A46.9050600@majjas.com>
 <20100117221746.GA3161@del.dom.local> <4B53906B.2020608@majjas.com>
 <20100117230531.GC3161@del.dom.local> <4B539A0A.2000504@majjas.com>
 <20100118073018.GA6270@ff.dom.local> <4B548C6B.10607@majjas.com>
 <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com>
 <20100118130038.77a3adfb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:54552 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754863Ab0ARVZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 16:25:59 -0500
In-reply-to: <20100118130038.77a3adfb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/18/2010 4:00 PM, Stephen Hemminger wrote:
> On Mon, 18 Jan 2010 15:56:45 -0500
> Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>>>> 2. The dropped tx packet (DHCP) is a bit harder to recreate, but it
>>>> still happens.
>>>>
>>>>          
> You might want to use tc filter rule to set priority of DHCP packets
> higher. This would cause them to be in a separate queue and eliminate
> the problem.
>
>    
Ok - for fun, tried that - no change. Not sure I see why this might be a 
factor. The packet loss happens when TX load is low and RX high.
Also,  packets only being dropped if traversing a router vs.to  the 
router itself.  Keep in mind that pings to the router did not lose 
packets, pings through the router lost packets. The router was not under 
load (traffic is being generated from a device connected via the 1Gb 
switch, not the wifi router), and tcpdump on the router input port shows 
the pings to the router, but not the ones through the router.

One added note, when I just tried this, the test data ended while the 
packet loss was occurring. The DHCPOFFER packet loss did not clear until 
about a minute after the throughput abated. I really think something is 
getting hosed, and I'd but some weird interaction with the arp logic 
high on the list of suspects. Not sure what else would be a factor when 
looking at the extra hop on the same subnet.
