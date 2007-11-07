From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Why does a connect to IPv6 LLA address fail ?
Date: Wed, 07 Nov 2007 14:42:19 -0500
Message-ID: <4732151B.70309@hp.com>
References: <20071107094007.GA15575@pingi.kke.suse.de> <20071107112838.GA22180@dhcp79.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, kkeil@suse.de
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:53427 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbXKGTzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 14:55:04 -0500
In-Reply-To: <20071107112838.GA22180@dhcp79.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Bohac wrote:
> Hi,
> 
>> For this it create a socket for datagram and
>> protocol IPPROTO_IP and then try to connect it with the destination
>> address. This fails in the case of a LLA, because connect returns EINVAL,
>> since here is no device bind to this socket at this time.
> 
> [snip]
> 
>> Why do we have this check in ip6_datagram_connect() ?
> 
> This problem has been nicely described in
> http://www.linux-ipv6.org/ml/usagi-users/msg03062.html
> without any response. 
> 
> RFC2461, Appendix A, really suggests performing neighbour
> discovery on all the links. I like the idea, it would make LLAs
> much more useful. 

The reason this is in an Appendix is because it doesn't work all
the time.  It was there to document some experiments that were going
on.

> 
> Has anyone experimented with this? Is there any good reason why
> we don't send NSs to all the links to find out which link the
> destination LLA is on?

The reason is that 2 different hosts may have the same link-local
address as long as they are on different links.  If the sender is
connected to both links then it may send the packet to the wrong
destination.

Link local addresses are unqualified without the scope/zone id.
The application must pass this information to the kernel as part of
the connect() call.

A different and some might say 'better' alternative is to define a
default link.  Thus when the zone id is not specified the default is used.
This will work fine for link-scoped addresses.  A default zone would also
need to be defined for other scopes as well.  That's just one idea.

-vlad
