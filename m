From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: Fix IPv6 PMTU disc. w/ asymmetric routes
Date: Sun, 3 Oct 2010 17:21:46 -0700
Message-ID: <AANLkTi=spyusBeETGxf92ZsfNSSadhNocggjRnEeF5X+@mail.gmail.com>
References: <20100928.135800.39205209.davem@davemloft.net>
	<AANLkTi=9THOcD9FieK3uy635C1kNDc=uEdtDe4qm1WU6@mail.gmail.com>
	<20100930.004136.91329579.davem@davemloft.net>
	<20101003.144931.71122620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53857 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425Ab0JDAVr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 20:21:47 -0400
Received: by wyb28 with SMTP id 28so4450995wyb.19
        for <netdev@vger.kernel.org>; Sun, 03 Oct 2010 17:21:46 -0700 (PDT)
In-Reply-To: <20101003.144931.71122620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ok, meanwhile I did the research.
>
> What ipv6 does is that when you lookup a route, it clones or copies
> the prefixes route into one that is fully specified for a specific
> SADDR/DADDR pair, and then inserts that specific route into the FIB6
> tree.
>
> Therefore the only cases we should lookup for PMTU discovery for ipv6
> are:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ daddr, saddr, ifindex =3D=3D 0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{ daddr, saddr, ifindex =3D=3D dev->ifinde=
x }
>
> This achieves the same effect as what ipv4 is doing.
>
> So Maciej your original attempt was correct all along, and as a resul=
t
> I'll commit the following.
>
> Thanks!

Awesome.  I've been trying to convince myself of this and come up with
a concise explanation - but it sounds like you got there first.

[I ran into SUBTREES and got stuck in trying to understand exactly how
they work and whether they affect this at all.]
