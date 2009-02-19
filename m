From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 20:11:06 -0500
Message-ID: <499CB1AA.70801@hp.com>
References: <20090218135537.GF3600@mini-me.lan>	<06F54D7E-EE07-49C9-AD8F-B46BD6B02ABA@oracle.com>	<499C5486.5020807@hp.com> <20090218.141431.103832064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:11817 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbZBSBLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:11:10 -0500
In-Reply-To: <20090218.141431.103832064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Wed, 18 Feb 2009 13:33:42 -0500
> 
>> Would a module parameter that disables ipv6 or at least addrconf be
>> enough of a solution?
> 
> We have it, it's just that (as others have stated) it doesn't
> prevent IPV6 sockets from being openned by applications.
> 

Is that what people really want to block?

Or do they want to prevent the use of IPv6 in environments where
IPv6 is not supported?  If it's this case, then simply not configuring
any IPv6 addresses on the system interfaces will make it seem as if
IPv6 is not there.

Without IPv6 addresses, AF_INET6 sockets are the same as AF_INET.
I really see no reason to block them.  Any legacy apps that people
might worry about don't use this type socket any way.

One doesn't even need to worry about processing IPv6 traffic,
since the system would never join any IPv6 multicast groups and thus
would never see 99% of the traffic.

-vlad
