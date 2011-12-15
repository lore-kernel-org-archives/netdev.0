From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: Weird linux kernel behavior - ARP - V2.6.16
Date: Wed, 14 Dec 2011 16:15:05 -0800
Message-ID: <4EE93C09.3090302@hp.com>
References: <CAGeZV=TeKwzhpxsEV_rNa0=R-RYZfy6qi0iLoZ5Y4tSA8Ti5qA@mail.gmail.com> <CA+55aFzZHMd=pCUum3dr+Lz+i1KJfooqNT2fi8Fumq3c8BexkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:32067 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165Ab1LOAPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 19:15:07 -0500
In-Reply-To: <CA+55aFzZHMd=pCUum3dr+Lz+i1KJfooqNT2fi8Fumq3c8BexkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2011 03:57 PM, Linus Torvalds wrote:
> Sent to some wrong people. Is anybody interested in this particular
> misconfiguration? Is it intentional/wanted, or just a "don't do that
> then"?

Configuring one's own IP address as the gateway is how one can use/rely 
on "Proxy ARP" whereby the router(s) on your subnet act as proxies for 
destinations beyond them by responding to the ARP requests one's system 
sends for them.  http://en.wikipedia.org/wiki/Proxy_ARP  Goes back a 
very long way to days before the current ubiquity of network auto 
configuration for things like default gateways.  (As implied by the 
rather low RFC numbers and date on the Stevens book referenced by the 
wikipedia entry).  The aging of the ARP cache entries enabled a form of 
protocol free (relative to the end system) gateway failover - assuming 
the gateways/routers on the subnet were able to decide among themselves 
who would respond for what, when one of them failed, the aging of the 
ARP cache entry and subsequent validation by the end systems would 
pick-up the non-failed router's/gateway's MAC address.  Happiness and 
Joy ensues.

So, it would be normal for such a system to try to ARP for any IP 
address it was trying to reach.

It would not be normal for such a system to spontaneously decide to try 
to ARP for IPs it was not trying to reach.

Which of those two situations was taking place wasn't entirely clear 
from the forwarded message.

rick jones

>
>                        Linus
>
>
> ---------- Forwarded message ----------
> From: Isaac Theogaraj<isaactheogaraj@gmail.com>
> Date: Wed, Dec 14, 2011 at 1:59 AM
> Subject: Weird linux kernel behavior - ARP - V2.6.16
> To: torvalds@osdl.org
> Cc: mtosatti@redhat.com, alan@lxorguk.ukuu.org.uk, tao@acc.umu.se
>
>
> Dear Kernel experts,
> I just encountered a kernel behavior wherein if the default gateway
> is set as an interface IP itself, kernel starts ARPing for every
> internet address.
> Would like to what is the intention behind this behavior?
>
> Of course this is an inadvertent configuration(wrong config. too),
> but when kernel ARPs for all internet addresses, that bloats up
> network tables in the routing/bridging devices.
>
> Logically speaking, if I say "My default gateway is me", then it's
> like saying that I have all routes and ARP resolutions. If I don't
> have a connected network for a destination, I drop it.
>
> Can you please let me know, why is the behavior set as "ARPing for
> every internet address" when "Default gateway is me"?
> thanks in advance,
> Isaac.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
