From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 14:55:20 -0400
Message-ID: <4A242418.1090804@hp.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc> <4A240681.2010300@6wind.com> <4A242161.3010609@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:12106 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbZFASzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 14:55:21 -0400
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
>=20
> (terminology : gateway / host in rfc 792)
>=20
> I would say : who sent this ttl=3D0 packet at first ?
>=20
> ping -t 0 host
> ping: can't set unicast time-to-live: Invalid argument
>=20
> So Linux is not able to do that, unless using tricks of course, or pa=
tching IP_TTL

'ping6 -t 0 host' does work however.  The problem I see is that if you =
ping a system,
if it's a host it will respond, if it's a router it won't - the RFCs do=
n't
explicitly state the host should drop the packet.  I don't know if that=
 difference
in behavior is desired.  Do we know how any other OSes behave?

-Brian
