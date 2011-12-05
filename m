From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: `ip addr show' shows maximum of 56 addresses?
Date: Mon, 05 Dec 2011 22:58:40 +0100
Message-ID: <1323122320.2467.7.camel@edumazet-laptop>
References: <E46EABF5-E03F-4DF3-82C8-21017B0FD1A7@bjencks.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Jencks <ben@bjencks.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46382 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480Ab1LEV6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 16:58:44 -0500
Received: by eeaq14 with SMTP id q14so2350695eea.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 13:58:43 -0800 (PST)
In-Reply-To: <E46EABF5-E03F-4DF3-82C8-21017B0FD1A7@bjencks.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 d=C3=A9cembre 2011 =C3=A0 16:12 -0500, Ben Jencks a =C3=A9c=
rit :
> I'm finding that ip addr show will only give me up to 56 addresses:
>=20
> $ ip -6 addr show lo
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436=20
>     inet6 ::1/128 scope host=20
>        valid_lft forever preferred_lft forever
> $ for i in `seq 55` ; do sudo ip addr del fd9a:704e:4d65:136d::`print=
f '%x\n' $i`/128 dev lo ; done
> $ ip addr show lo | grep inet6 | wc -l
> 56
> $ ip addr show lo | grep ' ::1'
>     inet6 ::1/128 scope host=20
> $ sudo ip addr add fd9a:704e:4d65:136d::`printf '%x\n' 56`/128 dev lo
> $ ip addr show lo | grep inet6 | wc -l
> 56
> $ ifconfig lo | grep inet6 | wc -l
> 57
> $ ip addr show lo | grep ' ::1'
> <no output>
>=20
> It doesn't even help to specify the address explicitly:
>=20
> $ ip addr show dev lo to ::1
> <no output>
>=20
> (Ubuntu kernel 2.6.32, tested with both distributed and latest git ip=
route2)
>=20
> I searched for this issue, and even looked in the iproute2/ip/ipaddre=
ss.c and couldn't find any explicit limits. Is there a maximum netlink =
message size causing problems?
>=20
> Sorry if this question is too user-ish for a dev list, but both linux=
-net and lartc looked dead.
>=20
> Thanks,
> -Ben--

This was fixed two years ago by commit bcd323262a94b14b in 2.6.33
(ipv6: Allow inet6_dump_addr() to handle more than 64 addresses)
