From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 11:30:43 +0200
Message-ID: <4A24F143.8020006@dev.6wind.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc> <4A240681.2010300@6wind.com> <4A242161.3010609@cosmosbay.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:4816 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbZFBKDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 06:03:30 -0400
In-Reply-To: <4A242161.3010609@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Nicolas Dichtel a =E9crit :
>> Le 01.06.2009 18:19, Florian Westphal a =E9crit :
>>> Nicolas Dichtel <nicolas.dichtel@dev.6wind.com> wrote:
>>>> when network stack receives a packet, it didn't check value of
>>>> ttl/hop limit
>>>> field. RFC indicates that a router must drop the packet if this fi=
eld
>>>> is 0.
>>> Whats wrong with the checks in ip(6)_forward?
>> It's on forward, not on input. Router must not process it.
>> For example, if you try to ping (with ttl set to 0) the router, you =
will
>> receive a reply.
>>
>=20
> You seem to mix requirements for routers and hosts. ttl processing
> is relevant for a gateway only, not for a host.
It's why I test the forwarding value in my patch. If forwarding is=20
enable, it's a router.

>=20
> (terminology : gateway / host in rfc 792)
>=20
> I would say : who sent this ttl=3D0 packet at first ?
I prefere to ask: is this packet a "legal" packet?

>=20
> ping -t 0 host
> ping: can't set unicast time-to-live: Invalid argument
>=20
> So Linux is not able to do that, unless using tricks of course, or pa=
tching IP_TTL
>=20
> BTW, sending ttl=3D0 packets to my cisco host (also a router but not =
relevant)
> is ok, it replies to this packets...
>=20
> I wonder why Linux forbids sending ttl=3D0 packets, time to read agai=
n all these RFCs :)
I find a statement which tell to drop the packet but maybe I've missing=
=20
something.


Nicolas
