From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 21:17:35 +0200
Message-ID: <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60231 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333AbbKCTRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 14:17:41 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id C9E7448074D
	for <netdev@vger.kernel.org>; Tue,  3 Nov 2015 21:17:39 +0200 (EET)
In-Reply-To: <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-03 21:11, Eric Dumazet wrote:
> On Tue, 2015-11-03 at 19:33 +0200, Denys Fedoryshchenko wrote:
>> Hi
>> 
>> Recently i was testing shaping over single 10G cards, for speeds up to
>> 3-4Gbps, and noticed interesting effect.
>> 
>> Shaping scheme:
>> Incoming bandwidth comes to switch port, with access vlan 100
>> Outgoing bandwidth leaves switch port with access vlan 200
>> Linux with Intel X710 connected to trunk port, bridge created, 
>> eth0.100
>> bridged to eth0.200
>> gso/gro/tso disabled (they doesn't work nice with shapers)
> 
> Well, this seems urban legend to me.
> 
> Something that is repeatedly copied/pasted on many web pages since last
> century.
> 
> Given the nature of qdisc (being protected by a spinlock), you
> absolutely want to have some kind of aggregation.
> 
> I have a patch to allow a sysadmin to set a max gro segs value to
> incoming packets. You could play with it. Start with 4 segments,
> allow GSO/TSO on the output and watch performance coming back.

It is not, since i have more than 120 servers installed over country 
(most of them handle small traffic), in forwarding mode, first thing i 
am doing on forwarding setup - disabling gro/gso/tso. It is helped also 
many ISP on their forum where i visit often, first thing in 
troubleshooting unreliable network traffic forwarding - disabling 
offloading.
Because problem starts from incorrect shaping, and ends in some cases 
with network drivers spitting watchdog errors. Sometimes even shaper not 
necessary, just plain forwarding with offload enabled can cause issues, 
but it might be bug in networking drivers.
Should i try to reproduce and report? Sure if anybody can look into this 
issue.
