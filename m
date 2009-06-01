From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 20:43:45 +0200
Message-ID: <4A242161.3010609@cosmosbay.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc> <4A240681.2010300@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53602 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755730AbZFASn5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 14:43:57 -0400
In-Reply-To: <4A240681.2010300@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel a =E9crit :
> Le 01.06.2009 18:19, Florian Westphal a =E9crit :
>> Nicolas Dichtel <nicolas.dichtel@dev.6wind.com> wrote:
>>> when network stack receives a packet, it didn't check value of
>>> ttl/hop limit
>>> field. RFC indicates that a router must drop the packet if this fie=
ld
>>> is 0.
>>
>> Whats wrong with the checks in ip(6)_forward?
> It's on forward, not on input. Router must not process it.
> For example, if you try to ping (with ttl set to 0) the router, you w=
ill
> receive a reply.
>=20

You seem to mix requirements for routers and hosts. ttl processing
is relevant for a gateway only, not for a host.

(terminology : gateway / host in rfc 792)

I would say : who sent this ttl=3D0 packet at first ?

ping -t 0 host
ping: can't set unicast time-to-live: Invalid argument

So Linux is not able to do that, unless using tricks of course, or patc=
hing IP_TTL

BTW, sending ttl=3D0 packets to my cisco host (also a router but not re=
levant)
is ok, it replies to this packets...

I wonder why Linux forbids sending ttl=3D0 packets, time to read again =
all these RFCs :)


