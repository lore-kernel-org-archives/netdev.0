From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
Date: Wed, 25 Mar 2009 11:54:02 -0400
Message-ID: <49CA539A.4080202@hp.com>
References: <> <1237945752-14362-1-git-send-email-brian.haley@hp.com> <49C99315.6070504@hp.com> <49CA2533.3000408@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, linux@kolla.no,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43990 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbZCYPyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 11:54:10 -0400
In-Reply-To: <49CA2533.3000408@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich wrote:
> Oh,  and another issue I just figured out this morning...

>>> Add 'autoconf' and 'disable_ipv6' parameters to the IPv6 module.
>>>
>>> The first controls if IPv6 addresses are autoconfigured from
>>> prefixes received in Router Advertisements.  The IPv6 loopback
>>> (::1) and link-local addresses are still configured.
> 
> You are letting link-locals to autoconfigure, but did not correctly
> finish DAD, because once you set disable_ipv6, ip6_output and ipv6_rcv
> will drop all IPv6 packets.
> 
> Then later, when you re-enable IPv6, you will not run DAD because the
> interface will think that it's already finished.
> 
> So there is a possibility of duplicates not being detected.

If you just set autoconf=0 and don't set disable_ipv6=1, then DAD will 
complete for the link-locals just fine.  If you "disable" them both you 
won't get any addresses at all.

So I guess your point is that if you then enable IPv6 on an interface 
and it gets a prefix in an RA, you'll add a global without having 
link-local?  It almost looked like the code in addrconf_prefix_rcv() 
prevented that from happening (ipv6_inherit_eui64()), but it doesn't.

-Brian

