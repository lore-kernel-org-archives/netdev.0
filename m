From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 11:30:56 +0200
Message-ID: <4A24F150.4090800@dev.6wind.com>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc> <4A240681.2010300@6wind.com> <4A242161.3010609@cosmosbay.com> <4A242418.1090804@hp.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:4814 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755129AbZFBKDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 06:03:30 -0400
In-Reply-To: <4A242418.1090804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> Eric Dumazet wrote:
>> Nicolas Dichtel a =E9crit :
>>> Le 01.06.2009 18:19, Florian Westphal a =E9crit :
>>>> Nicolas Dichtel <nicolas.dichtel@dev.6wind.com> wrote:
>>>>> when network stack receives a packet, it didn't check value of
>>>>> ttl/hop limit
>>>>> field. RFC indicates that a router must drop the packet if this f=
ield
>>>>> is 0.
>>>> Whats wrong with the checks in ip(6)_forward?
>>> It's on forward, not on input. Router must not process it.
>>> For example, if you try to ping (with ttl set to 0) the router, you=
 will
>>> receive a reply.
>>>
>> You seem to mix requirements for routers and hosts. ttl processing
>> is relevant for a gateway only, not for a host.
>>
>> (terminology : gateway / host in rfc 792)
>>
>> I would say : who sent this ttl=3D0 packet at first ?
>>
>> ping -t 0 host
>> ping: can't set unicast time-to-live: Invalid argument
>>
>> So Linux is not able to do that, unless using tricks of course, or p=
atching IP_TTL
>=20
> 'ping6 -t 0 host' does work however.  The problem I see is that if yo=
u ping a system,
> if it's a host it will respond, if it's a router it won't - the RFCs =
don't
> explicitly state the host should drop the packet.  I don't know if th=
at difference
> in behavior is desired.  Do we know how any other OSes behave?
I've ask the IETF mailing list about host case. Response was:
"process as normal."

Nicolas

>=20
> -Brian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
