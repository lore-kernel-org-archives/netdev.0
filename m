From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: arp_filter and IPv6 ND
Date: Tue, 6 Dec 2016 13:07:38 +0100
Message-ID: <84c9b65c-f7b1-f59b-50ce-f86f97754707@stressinduktion.org>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
 <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
 <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com>
 <cead0544-5a5b-ccd0-e02d-abb44a41c054@stressinduktion.org>
 <CAAeewD_erNdBw-zjPP9iFuju6FDgAgWrMKhMXPb58nqa0r22rA@mail.gmail.com>
 <96111ae8-9b68-943f-c9be-8fccdd614c8b@stressinduktion.org>
 <CAAeewD9CDQZp0u6L6JtZ96cboKDCRB=yY92F+-ufsA8=OEgyUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Saku Ytti <saku@ytti.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36332 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751492AbcLFMHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:07:41 -0500
In-Reply-To: <CAAeewD9CDQZp0u6L6JtZ96cboKDCRB=yY92F+-ufsA8=OEgyUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.12.2016 15:21, Saku Ytti wrote:
> On 2 December 2016 at 20:39, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> 
> Hey,
> 
>> E.g. you can use IP addresses bound to other interfaces to send replys
>> on another interface. This can be useful if you have a limited amount of
>> IP addresses on the system but much more interfaces. Especially if they
>> are limited in scope, like in IPv6.
>>
>> Basically Cisco's feature of "unnumbered interface" is always provided
>> in Linux. And there are certainly cases where you would want to use it,
>> e.g. emulate private-vlan feature for network separation.
> 
> Got it, thanks, the explanation makes sense. And indeed it's valid
> case, but also it is the exception, not the rule. I think it would be
> entirely change the default and people who want 'unnumbered' style
> behaviour (like some BRAS scenarios), will know how to and why to
> configure it.

The limited ip address scenario is actually more common for normal
routers. ;)

In retrospect I don't know what what would win if the decision would be
made again. Mostly all operating systems switched to strong end host
model over time, Linux remaining in the weak host end camp alone. It
probably is also easier to go from strong end to weak end system by
policy than vice versa, so I would probably also picked strong end
system semantics by default today.

>> Also in the BGP setup, you might have it easier to establish loopback
>> neighbor contact by just using static on-link routes, without caring
>> about more complex numbering there (otherwise you pretty soon introduce
>> OSPF or some other routing protocol to do the recursive forward resolution).
> 
> The BGP is running on-link, it's just that the BGP is advertising loop
> of Linux. Why the loop ends up in ND cache, I don't know.

Did you check neighbor advertisements and solicitations with tcpdump?

Did you have force_tllao, ndisc_notify enabled? Which source address
does the BGP/TCP connection use?

>>> Grand, not that I feel comfortable writing it. I'd rather see the
>>> whole suppression functionality moved to neighbour.c from being AFI
>>> specific.
>>
>> Yes sure, please provide a patch. A separate sysctl is necessary anyway
>> because the current one is within the ipv4 procfs directory hierarchy.
> 
> Sorry, not a comfortable C programmer, I'm pretty confident I could
> get it working, but I'm more confident that patch would be entirely
> rejected and rewritten by someone who knows what they are doing.
> I see no reason not to have AFI specific toggle, just logic and code
> should be AFI agnostic, like GC (ARP/ND cache time) stuff in
> neighbour.c is nicely done. Frankly whole ARP/ND code could do with
> refactoring to make arp.c and ndisc.c more wire-format stuff and
> behavioural code more in neighbour.c.

Let's first see what the real problem is.
