From: Dries De Winter <dries.dewinter@gmail.com>
Subject: Re: [PATCH] net: ICMPv6 packets transmitted on wrong interface if
 nfmark is mangled
Date: Thu, 6 Dec 2012 10:11:23 +0100
Message-ID: <CA+e04fgTfSYppUHZkv0DaTawHEOKA-YXiahEJwTS75ndkK1TXw@mail.gmail.com>
References: <CA+e04fjWMDE9xEApysFRprZDBdM3Ya2RHrxtoau7i+fxzGT8CQ@mail.gmail.com>
	<20121203.170636.1325623456787407245.davem@davemloft.net>
	<CA+e04fgiMDoaCx0fpdK5F6YfJ_CSOZ13q1fn9xs7De4JO02c6g@mail.gmail.com>
	<20121205.125700.2246243377198648534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pablo@netfilter.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:38761 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422626Ab2LFJLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 04:11:25 -0500
In-Reply-To: <20121205.125700.2246243377198648534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/5 David Miller <davem@davemloft.net>:
> From: Dries De Winter <dries.dewinter@gmail.com>
> Date: Wed, 5 Dec 2012 14:41:59 +0100
>
>> My "noreroute" patch will not fix this. Therefore it's indeed maybe
>> better to add a simple check to ip6_route_me_harder(): not a check for
>> ICMPv6, but a check for (ipv6_addr_type(&iph->daddr) &
>> IPV6_ADDR_LINKLOCAL) instead. What do you think?
>
> What if a packet is rewritten from a non-link-local destination address
> into a link-local one?  Or vice versa?
>
> Your test will fail in those cases.

You are saying that the decision should be based on the original
destination address rather the modified one? I would say the opposite:

- If a non-link-local destination is changed into a link-local one, it
should certainly not be rerouted because routing doesn't make much
sense for link-local destinations.

- If a link-local destination is changed into a non-link-local one,
why not reroute it according to the new destination?

If you do not agree, we can also put the check in
ip6t_local_out_hook() where the original destination is still
available.

Dries.
