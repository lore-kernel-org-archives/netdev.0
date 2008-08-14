From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: interface down: v6/v4 address deletion difference
Date: Thu, 14 Aug 2008 16:24:56 -0400
Message-ID: <48A49498.4010601@hp.com>
References: <alpine.LRH.1.10.0808142017050.23001@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:17204 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700AbYHNUY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 16:24:59 -0400
In-Reply-To: <alpine.LRH.1.10.0808142017050.23001@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka Savola wrote:
> Hi,
> 
> I recall there was discussion about this a couple of years back, but I
> couldn't find it for all I could try.
> 
> There seems to be a difference in how v4/v6 addresses are handled when
> interface goes down (manually added addresses are gone forever
> regardless of whether it's tentative or nor; link local address is
> deleted but reappears when link is back).
> 
> Example on 2.6.25.10-86.fc9 using pan0 interface (just because it's
> easiest to play with it):
> 
> # ip l set up dev pan
> # ip a a 10.0.0.1/24 dev pan0
> # ip -6 a a 2001::1/64 dev pan0
> # ip a l dev pan0
> 8: pan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
> UNKNOWN
>     link/ether 36:ca:62:2a:71:7b brd ff:ff:ff:ff:ff:ff
>     inet 10.0.0.1/24 scope global pan0
>     inet6 2001::1/64 scope global
>        valid_lft forever preferred_lft forever
>     inet6 fe80::34ca:62ff:fe2a:717b/64 scope link
>        valid_lft forever preferred_lft forever
> # ip l set down dev pan0
> # ip a l dev pan0
> 8: pan0: <BROADCAST,MULTICAST> mtu 1500 qdisc noqueue state DOWN
>     link/ether 36:ca:62:2a:71:7b brd ff:ff:ff:ff:ff:ff
>     inet 10.0.0.1/24 scope global pan0
> # ip l set up dev pan0
> # ip a l dev pan0
> 8: pan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
> UNKNOWN
>     link/ether 36:ca:62:2a:71:7b brd ff:ff:ff:ff:ff:ff
>     inet 10.0.0.1/24 scope global pan0
>     inet6 fe80::34ca:62ff:fe2a:717b/64 scope link tentative
>        valid_lft forever preferred_lft forever
> (and after a while 'tentative' flag goes away)
> 
> Shouldn't behaviour be consistent across v4/v6?
> 

>From what I remember explained to me, this is due to different
host models of operation between IPv4 and IPv6 in linux.  IPv4 is
implemented using a weak host mode, while IPv6 is a strong host model.
So, when the interface is brought down, all IPv6 addresses
are removed since Linux considers them assigned to the interface
and not the host.

-vlad
