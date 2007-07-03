From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Tue, 03 Jul 2007 08:42:33 -0400
Message-ID: <1183466553.5159.51.camel@localhost>
References: <1183167053.5153.7.camel@localhost>
	 <20070629.213503.34601850.davem@davemloft.net>
	 <1183215164.5165.13.camel@localhost>
	 <20070630.133357.77057070.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:8189 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbXGCMmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 08:42:38 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1780697wxd
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 05:42:37 -0700 (PDT)
In-Reply-To: <20070630.133357.77057070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-30-06 at 13:33 -0700, David Miller wrote:

> It's like twice as fast, since the switch doesn't have to copy
> the packet in, switch it, then the destination guest copies it
> into it's address space.
> 
> There is approximately one copy for each hop you go over through these
> virtual devices.

Ok - i see what you are getting at, and while it makes more sense to me
now, let me continue to be _the_ devils advocate (sip some esspresso
before responding or reading): 
for some reason i always thought that packets going across these things
(likely not in the case of hypervisor based virtualization like Xen)
just have their skbs cloned when crossing domains, is that not the
case?[1]
Assuming they copy, the balance that needs to be stricken now is
between:

a) copy is expensive
vs
b1) For N guests, N^2 queues in the system vs N queues and 1 vs N
replicated global info.
b2) The architecture challenges to resolve the fact you now have to deal
with a mesh (1-1 mapping) instead of star topology between the guests. 

I dont think #b1 is such a big deal; in the old days when i had played
with what is now openvz, i was happy to get 1024 virtual routers/guests
(each running Zebra/OSPF). I could live with a little more wasted memory
if the copy is reduced.
I think sub-consciously i am questioning #b2. Do you really need that
sacrifice just so that you can avoid one extra copy between two guests?
If i was running virtual routers or servers i think the majority of
traffic (by far) would be between a domain and outside of the box not
between any two domains within the same box. 

cheers,
jamal


[1] But then if this is true, i can think of a simple way to attack the
other domains by inserting a kernel module into a domain that reduced
the refcount of each received skb to 0. I would be suprised if the
openvz type approach hasnt thought this through.


