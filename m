From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: IPv6 address printf format specifier
Date: Wed, 18 Mar 2009 22:26:30 -0400
Message-ID: <49C1AD56.5000608@hp.com>
References: <4B97CD05-9949-485D-987E-A555FCBC2F5A@oracle.com>	<49BE889C.8080602@hp.com> <20090318.185826.221840814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:18911 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZCSC0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 22:26:33 -0400
In-Reply-To: <20090318.185826.221840814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 16 Mar 2009 13:13:00 -0400
> 
>> Chuck Lever wrote:
>>> The NFS and RPC code in the kernel now uses the new printf format
>>> specifier for IPv6 addresses.  In some cases, the generated address
>>> string is sent out of the kernel (for example, it is used to build a
>>> universal address for RPCB_SET requests, and used as the mon_name in
>>> some SM_MON upcalls to our rpc.statd).
>>>
>>> The problem is that outside the kernel, applications generally use
>>> getnameinfo(3) or inet_ntop(3) to do this conversion.  The library
>>> follows the RFC suggestion of shortening these address strings by
>>> replacing the longest series of zeroes in the IPv6 address with "::".
>>>
>>> Since the kernel doesn't do that, string comparisons don't work when
>>> comparing address strings that came from our kernel.  Since these
>>> address strings appear to other hosts (via the rpcbind registry) this
>>> is, or could become, an interoperability issue for Linux.
>>>
>>> How should I fix this?
>>>
>>> 1.  Copy glibc's code to the printf logic for %pI6
>> I think this is the optimum solution.  This normalizes kernel output
>> with that of user-space thus creating a uniform format.
>>
>> My $0.02
> 
> Then you'll break cases where this string is output via
> some /proc/ file or whatever and it expects the existing
> behavior.
> 
> I don't think we can do this.
> 

Ugh... you are right.  Changing the formating across the board is a non-starter,
as much as I would still like to see it.

Upon rereading Chunk's text and re-reading RFC 2732 and RFC 4291, I've come
to the conclusion that any application that attempts to compare textual
representations of IPv6 addresses is misguided at best.

There are multiple different forms of presenting addresses, all of which
are valid and non of which will provide for sting equality.  Regardless of
how we represent our IPv6 addresses, there is a chance that it will cause
interoperability issues and the only way to truly solve it is to change
applications to compare addresses in their true numerical representation.

-vlad
