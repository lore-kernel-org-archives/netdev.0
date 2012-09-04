From: Bob Gilligan <gilligan@aristanetworks.com>
Subject: Re: [PATCH 1/2] ipv4: Improve the scaling of the ARP cache for multicast
 destinations.
Date: Mon, 03 Sep 2012 21:22:02 -0700
Message-ID: <504581EA.8040807@aristanetworks.com>
References: <50400B68.3060302@aristanetworks.com> <20120830.210628.365120808137655227.davem@davemloft.net> <50410EB8.3040603@aristanetworks.com> <50435E6B.5040007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38428 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab2IDEWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 00:22:06 -0400
Received: by pbbrr13 with SMTP id rr13so8867126pbb.19
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2012 21:22:05 -0700 (PDT)
In-Reply-To: <50435E6B.5040007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/12 6:26 AM, Nicolas de Peslo=FCan wrote:
> Le 31/08/2012 21:21, Bob Gilligan a =E9crit :
>> On 8/30/12 6:06 PM, David Miller wrote:
>>> From: Bob Gilligan<gilligan@aristanetworks.com>
>>> Date: Thu, 30 Aug 2012 17:55:04 -0700
>>>
>>>> The mapping from multicast IPv4 address to MAC address can just as
>>>> easily be done at the time a packet is to be sent.  With this chan=
ge,
>>>> we maintain one ARP cache entry for each interface that has at lea=
st
>>>> one multicast group member.  All routes to IPv4 multicast destinat=
ions
>>>> via a particular interface use the same ARP cache entry.  This ent=
ry
>>>> does not store the MAC address to use.  Instead, packets for multi=
cast
>>>> destinations go to a new output function that maps the destination
>>>> IPv4 multicast address into the MAC address and forms the MAC head=
er.
>>>
>>> Doing an ARP MC mapping on every packet is much more expensive than
>>> doing a copy of the hard header cache.
>>>
>>> I do not believe the memory consumption issue you use to justify th=
is
>>> change is a real issue.
>=20
> My two cents:
>=20
> Why do we need a per interface neighbor cache for multicast? Isn't th=
e
> target MAC expected to be the same for a give target multicast IP
> address, whatever the egress interface?
>=20
> Can't we store the target MAC for multicast address on a neighbor cac=
he
> entry with a fake dev value meaning "multicast"?
>=20
> Can't we detect the fact that the IP destination address is multicast
> and search only the neighbor cache entries that have this fake dev
> value, instead of the egress interface?
>=20
> This should reduce memory consumption (not N-squared anymore) without
> significantly increasing the CPU usage.
>=20
> Do I miss something?

Sounds like you are suggesting the converse of my proposed patch:  One
"special" Neighbor Cache Entry per multicast group instead of one per
interface.  Unfortunately, I don't think this will work.  Different MAC
types have different frame formats and different multicast address
mappings, so can't share a common neighbor cache entry.

Bob.
>=20
>     Nicolas.
