From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Mon, 10 Oct 2011 12:16:06 -0400
Message-ID: <4E931A46.1040905@hp.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	c@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:46843 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab1JJQXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:23:00 -0400
In-Reply-To: <20111005201559.E544016A599@drone1.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2011 04:15 PM, Lorenzo Colitti wrote:
> net: ipv6: Allow netlink to set IPv6 address scope
> 
> Currently, userspace cannot specify the scope of IPv6
> addresses when creating or modifying them. Instead, the
> scope is automatically determined from the address itself.
> In IPv4, userspace can set whatever scope it likes.
> 
> Allow userspace to specify the scope of IPv6 addresses in
> a backwards-compatible way: if the scope passed in is zero,
> use the old behaviour of automatically determining the
> scope based on the address.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Hi Lorenzo,

I remember someone proposing a similar patch before and it was not accepted, do
you have a use case for doing this?  It just seems like it will cause problems.

Also, there are other parts of the kernel (NFS, SCTP, IPv6 multicast) that are
still calling ipv6_addr_scope() on a plain address - won't those be broken since
they'll return the correct, RFC-implied scope?

-Brian
