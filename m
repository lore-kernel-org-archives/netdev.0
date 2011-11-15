From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TCLASS values
 via netlink
Date: Mon, 14 Nov 2011 22:13:28 -0800
Message-ID: <CAHo-OozYtgN9_TdOTs+40JKpSZmi2c-6yrbjFS2hViFv_QY-5Q@mail.gmail.com>
References: <CAHo-OozNP2qi_RMjO7rS1=fyaU8w_3aZZLptqnYAkCAwhQDj_w@mail.gmail.com>
	<20111109.205344.49946086292195784.davem@davemloft.net>
	<CAHo-OoybYpiusVFbDLEhS2ayPOVC1sXt7WZvpgW-Fk7ZqKj+SQ@mail.gmail.com>
	<20111114.010752.2129864130433732501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	MuraliRaja Muniraju <muralira@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50970 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab1KOGNb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 01:13:31 -0500
Received: by vws1 with SMTP id 1so5929968vws.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 22:13:30 -0800 (PST)
In-Reply-To: <20111114.010752.2129864130433732501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/13 David Miller <davem@davemloft.net>:
>>>> Yes, but an ipv6 socket is permitted to setsockopt SOL_IP in addit=
ion to SOL_IPV6.
>>>> As such, one can simply setsockopt(ipv6_socket, SOL_IP, IP_TOS, va=
lue).
>>>
>>> That's my whole point, this operation isn't currently possible, the
>>> socket ops for ipv4 setsockopt() aren't hooked up to ipv6 mapped
>>> sockets in the kernel right now.
>>
>> http://lxr.linux.no/linux+v3.1/net/ipv6/ipv6_sockglue.c#L822
>
> That definitely destroys the basis for all of my arguments :-)
>
> I'm going to add the TCLASS inet_diag patch, but can you find a clean=
er
> way to make sure that all types of sockets have the value initialized
> to something sane? =C2=A0The one you posted wasn't... optimal :-)
>
> Thanks.

I only realized just now that I had replied only to you and not to all.
I hope you don't mind that I'm adding everyone back into the loop.

(a) if we keep tos/tclass distinct.

We should make sure to get this patch (and the as yet unwritten
followup) into 3.2-final and not 3.3-rc1 (ie. net/master and not
net-next/master).
Since it does slightly change userspace visible API (thankfully, it
was just added so it's not yet too late to change it).
[FYI, I already see this patch in net/master - thanks!]

As for the followup, I can see three ways to proceed.
- The first involves figuring out what type of socket we're dealing
with when we look at it (ie. something like the RFC patch I posted - I
don't think it's going to be much prettier no matter what one does -
there's simply a lot of complexity...)
- The second involves keeping some sort of type-of-ip-socket
field/bitmap (none, ipv4 only, ipv4/ipv6 dual stack, ipv6 only)
directly in the socket.  This is probably much harder to get right
(changes all over the stack), but may have long term benefits???
- The third involves punting on the problem, we handle the simple
cases in kernel and sometimes return excess information to userspace
(ie. we take the RFC patch and strip out the address comparisons and
error on the side of returning 'true') -> it's userspace's problem to
sift through the excess garbage.

(b) personally I would still prefer to just merge tos and tclass and
get rid of the distinction... is this minor-but-userspace-visible-api
change out of the question?

- Maciej
