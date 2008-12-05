From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 multicast bind(), esp. v4-mapped addresses
Date: Fri, 5 Dec 2008 09:42:43 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0812050928340.28482@netcore.fi>
References: <alpine.LRH.2.00.0812050820380.28482@netcore.fi> <20081205.161117.109565135.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: =?ISO-2022-JP?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28J?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:47127 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbYLEHmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 02:42:54 -0500
In-Reply-To: <20081205.161117.109565135.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Dec 2008, YOSHIFUJI Hideaki / ???? wrote:
> I think similar issue(s) have been pointed out several times.
> IPv4-mapped addresses are not portable, unfortunately, anyway, and
> people should use native interface, especially for multicasts.

Yes, there are problems with portability of mapped address usage, but 
that doesn't have to mean that we shouldn't try to make it as useful 
as reasonable.

> BTW, do you know what kind of socket option do they use for 
> setting/getting ttl etc?
>
> If we fully support "IPv4-Mapped" function, we should transparently
> configure ipv4-multicast parameters etc. as well.

It does this:

setsockopt(7, SOL_IPV6, IPV6_MULTICAST_HOPS, [1], 4) = 0

In Java MulticastSocket API, if you only specify the port and not 
multicast group, it will bind to "::", and it succeeds.  Afterwards 
Java issues an IPv4 IGMP join:

setsockopt(7, SOL_IP, IP_ADD_MEMBERSHIP, "\351\f\f\f\0\0\0\0\0\0\0\0", 12) = 0

So Java implementation will parse whether the group is IPv4 or IPv6 
multicast -- it isn't using MCAST_JOIN_GROUP API.  It could be argued 
that if it already knows the protocol, it _could_ create IPv4 socket 
from the start, instead of doing this via a mapped v6 socket.

Of course, if Java used the protocol-independent MCAST_JOIN_GROUP etc. 
API, it would not need to even know whether the group was v4 or v6. 
And from that perspective also it would probably make sense to support 
a v4-mapped-address bind().

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
