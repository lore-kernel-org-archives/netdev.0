From: Saku Ytti <saku@ytti.fi>
Subject: Re: arp_filter and IPv6 ND
Date: Sat, 3 Dec 2016 16:21:17 +0200
Message-ID: <CAAeewD9CDQZp0u6L6JtZ96cboKDCRB=yY92F+-ufsA8=OEgyUw@mail.gmail.com>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
 <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
 <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com>
 <cead0544-5a5b-ccd0-e02d-abb44a41c054@stressinduktion.org>
 <CAAeewD_erNdBw-zjPP9iFuju6FDgAgWrMKhMXPb58nqa0r22rA@mail.gmail.com> <96111ae8-9b68-943f-c9be-8fccdd614c8b@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36133 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751987AbcLCOVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 09:21:19 -0500
Received: by mail-io0-f179.google.com with SMTP id m5so391104237ioe.3
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 06:21:18 -0800 (PST)
In-Reply-To: <96111ae8-9b68-943f-c9be-8fccdd614c8b@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 December 2016 at 20:39, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

Hey,

> E.g. you can use IP addresses bound to other interfaces to send replys
> on another interface. This can be useful if you have a limited amount of
> IP addresses on the system but much more interfaces. Especially if they
> are limited in scope, like in IPv6.
>
> Basically Cisco's feature of "unnumbered interface" is always provided
> in Linux. And there are certainly cases where you would want to use it,
> e.g. emulate private-vlan feature for network separation.

Got it, thanks, the explanation makes sense. And indeed it's valid
case, but also it is the exception, not the rule. I think it would be
entirely change the default and people who want 'unnumbered' style
behaviour (like some BRAS scenarios), will know how to and why to
configure it.

> Also in the BGP setup, you might have it easier to establish loopback
> neighbor contact by just using static on-link routes, without caring
> about more complex numbering there (otherwise you pretty soon introduce
> OSPF or some other routing protocol to do the recursive forward resolution).

The BGP is running on-link, it's just that the BGP is advertising loop
of Linux. Why the loop ends up in ND cache, I don't know.

>> Grand, not that I feel comfortable writing it. I'd rather see the
>> whole suppression functionality moved to neighbour.c from being AFI
>> specific.
>
> Yes sure, please provide a patch. A separate sysctl is necessary anyway
> because the current one is within the ipv4 procfs directory hierarchy.

Sorry, not a comfortable C programmer, I'm pretty confident I could
get it working, but I'm more confident that patch would be entirely
rejected and rewritten by someone who knows what they are doing.
I see no reason not to have AFI specific toggle, just logic and code
should be AFI agnostic, like GC (ARP/ND cache time) stuff in
neighbour.c is nicely done. Frankly whole ARP/ND code could do with
refactoring to make arp.c and ndisc.c more wire-format stuff and
behavioural code more in neighbour.c.


-- 
  ++ytti
