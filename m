From: Ulrich Weber <uweber@astaro.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Fri, 24 Sep 2010 17:38:48 +0200
Message-ID: <4C9CC608.7010401@astaro.com>
References: <20100922162209.GA10281@babylon>	 <20100922.203442.233700254.davem@davemloft.net>	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>	 <4C9CBCFC.6080300@gmail.com> <1285342083.2503.252.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-56.dex002.intermedia.net ([64.78.21.185]:10859 "EHLO
	dhost002-56.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753572Ab0IXPiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 11:38:55 -0400
In-Reply-To: <1285342083.2503.252.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, as I wrote before my Cable ISP is flooding me with
ARP requests from 10.0.0.0/8, which get a route
via the primary PPP link.

I know thats not a common setup but why do that
kind of routes have to be cached ? :)


steps to reproduce:
server:
 ip route add 1.0.0.0/8 dev dummy0

client:
 ip route add 1.0.0.0/8 dev eth0
 nmap --min-rate 500 -sP 1.0.0.0/8


On 09/24/2010 05:28 PM, Eric Dumazet wrote:
> Le vendredi 24 septembre 2010 =C3=A0 17:00 +0200, Ulrich Weber a =C3=A9=
crit :
>> Hi Eric,
>>
>> please find the output in the attached text file.
>>
>> Neighbor garbage collection wont't work because all
>> neighbor records are bound to cached routes.
>>
>> Forced route garbaged collections returns without freeing
>> any routes, probably because the route threshold is quite high
>> with 65536 compared to the small neighbor threshold of 1024,
>> resulting in a fixed amount of 1024 cached routes...
>>
>> Instead of running the garbage collection we could flush the route
>> cache completely if the neighbor cache overflows.
>> But why do we have to cache that routes in first place ?
>> See the previous patch which skips caching for that kind of routes.
>=20
> What are the packets you receive ? A flood of ARP answers ?
>=20
> a "tcpdump -X" of a few packets would help to understand.
>=20
>=20
>=20


--=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =E2=
=80=93200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
