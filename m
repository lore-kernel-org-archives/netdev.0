From: Herman Elfrink <herman.elfrink@ti-wmc.nl>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 30 May 2006 10:29:54 +0200
Message-ID: <447C0282.8010000@ti-wmc.nl>
References: <44731733.7000204@ti-wmc.nl> <20060524205035.GA4149@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Oosthoek <simon.oosthoek@ti-wmc.nl>,
	Alex Stienstra <alex.stienstra@ti-wmc.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darla.ti-wmc.nl ([217.114.97.45]:7341 "EHLO smtp.wmc")
	by vger.kernel.org with ESMTP id S932176AbWE3I3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 04:29:55 -0400
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20060524205035.GA4149@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:

>Hi!
>
>  
>
>>FLAME stands for "Forwarding Layer for Meshing"
>>
>>FLAME provides an intermediate layer between the network 
>>layer (e.g. IPv4/IPv6) and the link (MAC) layer, 
>>providing L2.5 meshing. Both network layer and MAC layer 
>>    
>>
>
>What is wrong with meshing on L3?
>
>(It is called flame so lets at least have nice flamewar :-)
>							Pavel
>  
>

Hi Pavel,

I basically have two arguments against L3 meshing, which, for me, were 
strong enough to turn to "below IP" meshing as a better solution for the 
problems I was facing.

The first one comes from my experimental setup where I want to use a ad 
hoc IPv6 network that has one or more Internet access gateways. With ad 
hoc I mean in this context that nodes can be plugged into and taken out 
of the network at any moment in time. If one would do this on a normal 
wired ethernet subnet, this works fine, thanks to the IPv6 
autoconfiguration capabilities: the Internet gateways transmit Router 
Advertisements, which are used by all other nodes to autoconfigure their 
own (global) IPv6 addresses.
When replacing the fixed ethernet by a meshed ad hoc wireless net, I 
would like this to work just the same.
Unfortunately, and here's the argument: basic L3 meshing does not allow 
that. It creates a routing domain instead of a subnet, and IPv6 
autoconfiguration does not work through routers. Similar problems occurs 
with broad- and multicast.
One way to solve this is to re-invent autoconfiguration specifically for 
L3 meshing, which is non-trivial, and which is exactly what is happening 
now in IETF, given the large amount of RFCs on this and related subjects.
Another solution is meshing below IP. Then your mesh network, from 
IP/IPv6 point of view, behaves like a normal subnet again, so all 
standard IP/IPv6 mechanism work as expected.
I've explored both solutions, spent several months on trying (and 
failing) to get OLSR to do what I wanted, and then spent a couple of 
weeks to create FLAME.

The second argument is that in the future meshing is going to be built 
into the relevant MAC layers (see 802.11s and corresponding efforts for 
e.g. Wimax and Zigbee),
so "below IP" seems the natural place to solve this.

Regards,

Herman.

