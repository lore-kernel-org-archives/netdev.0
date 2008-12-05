From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 multicast bind(), esp. v4-mapped addresses
Date: Fri, 05 Dec 2008 16:11:17 +0900 (JST)
Message-ID: <20081205.161117.109565135.yoshfuji@linux-ipv6.org>
References: <alpine.LRH.2.00.0812050820380.28482@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49846 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbYLEHhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 02:37:12 -0500
In-Reply-To: <alpine.LRH.2.00.0812050820380.28482@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <alpine.LRH.2.00.0812050820380.28482@netcore.fi> (at Fri, 5 Dec 2008 08:42:37 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> Two questions:
> 
>   1) should this be supported?  I think we're talking about a change in
>      net/ipv6/af_inet6.c, replacing something like (not tested, adapted
>      from net/ipv4/af_inet.c):
> 
> 273         if (addr_type == IPV6_ADDR_MAPPED) {
> 274                 v4addr = addr->sin6_addr.s6_addr32[3];
> 275                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
> 276                         err = -EADDRNOTAVAIL;
> 277                         goto out;
> 278                 }
> 279         } else {
> 
> with:
> 
>           if (addr_type == IPV6_ADDR_MAPPED) {
>                   v4addr = addr->sin6_addr.s6_addr32[3];
>  		 if (inet_addr_type(net, v4addr) == RTN_MULTICAST ||
>  		     inet_addr_type(net, v4addr) == RTN_BROADCAST) {
>  			inet->saddr = 0; /* Use device */
>                   } else {
>  	                 if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
>  	                         err = -EADDRNOTAVAIL;
>  	                         goto out;
>  	                 }
>  		}
>           } else {

I think similar issue(s) have been pointed out several times.
IPv4-mapped addresses are not portable, unfortunately, anyway, and
people should use native interface, especially for multicasts.

BTW, do you know what kind of socket option do they use for setting/getting
ttl etc?

If we fully support "IPv4-Mapped" function, we should transparently
configure ipv4-multicast parameters etc. as well.


>   2) it appears that ip_nonlocal_bind sysctl only supports ipv4.
>      Similar option or applying the same for v6 may be useful,
>      especially if 1) is not changed, such a toggle might be useful
>      with v6 as well.

I don't think this could not be an answer.

--yoshfuji
