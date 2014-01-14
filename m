From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Tue, 14 Jan 2014 15:14:02 -0800 (PST)
Message-ID: <20140114.151402.1121761875279304938.davem@davemloft.net>
References: <1389538427.32032.YahooMailBasic@web125505.mail.ne1.yahoo.com>
	<20140113011146.GG6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fx.lebail@yahoo.com, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaANXOD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:14:03 -0500
In-Reply-To: <20140113011146.GG6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 13 Jan 2014 02:11:46 +0100

> Hi!
>=20
> On Sun, Jan 12, 2014 at 06:53:47AM -0800, Fran=E7ois-Xavier Le Bail w=
rote:
>> On Sat, 1/11/14, Hannes Frederic Sowa <hannes@stressinduktion.org> w=
rote:
>>=20
>> > On Sat, Jan 11, 2014 at 05:38:27PM +0400, Alexey Kuznetsov wrote:
>> > > On Sat, Jan 11, 2014 at 5:06 PM, Fran=E7ois-Xavier Le Bail
>> > > <fx.lebail@yahoo.com> wrote:
>> > > > Many DNS root-servers use TCP with anycast (IPv4 and IPV6).
>> > >=20
>> > > Actually, I was alerted by reset processing in your patch, it ca=
nnot be right.
>> > >=20
>> > > Do not you think this must not be enabled for common use? At lea=
st
>> > > some separate sysctl disabled by default.
>>=20
>> > The idea I had, was, that if a socket does knowingly bind to an an=
ycast
>> > address, it is allowed to do so and process queries on it with bot=
h TCP and
>> > UDP. I don't think we need a sysctl for that? Anycast addresses ar=
e either
>> > pre-defined (e.g. the subnet router anycast address) or specified =
by a flag
>> > when the administrator adds one. Currently one can only add anycas=
t addresses
>> > either by forwarding and gets the per-subnet anycast address or wi=
th a
>> > setsockopt IPV6_JOIN_ANYCAST.
>>=20
>> > So the problem is what should be allowed when the socket listens o=
n an any
>> > address? Maybe this should be protected by a sysctl?
>>=20
>> TCP case:
>> With my two patches (the one for bind and this one for tcp), when a
>> SOCK_STREAM socket listen to in6addr_any, the server is able to=20
>> send TCP reply with unicast or anycast source address,=A0according
>> to the destination address used by the client.
>>=20
>> dest request unicast =3D> src reply unicast (current behavior)
>> dest resquet anycast =3D> src reply anycast (new)
>>=20
>> So, I don't think there is a need for a sysctl.
>=20
> I am still thinking about the RST-case and am a bit unsure here. But =
I
> currently don't see any problems.

I think this needs much more discussion and analysis before I can reall=
y
seriously consider applying this, sorry.
