From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux IPv6 router table size.
Date: Sun, 16 Jan 2011 09:44:22 +0100
Message-ID: <1295167463.3977.33.camel@edumazet-laptop>
References: <4D320D90.3090005@jhprins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jan Hugo Prins <jhp@jhprins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50449 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200Ab1APIoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 03:44:32 -0500
Received: by wyb28 with SMTP id 28so4185769wyb.19
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 00:44:30 -0800 (PST)
In-Reply-To: <4D320D90.3090005@jhprins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 15 janvier 2011 =C3=A0 22:11 +0100, Jan Hugo Prins a =C3=A9cr=
it :
> Hi netdev kernel developers,
>=20
> In the beginning of December the number of IPv6 routes in the BPG rou=
ter
> tables got somewhere close to 4096 and this number is somewhat magica=
l
> in Linux. Why is it magical? Well, the default setting for
> net.ipv6.route.max_size is hardcoded in the linux kernel to be exactl=
y
> this number, this in contradiction with the IPv4 net.ipv4.route.max_s=
ize
> which is set based upon the size of your memory. Actually, in the IPv=
4
> part of the kernel sources their is a route.c with a nice formula
> telling the kernel how big this number should be. For IPv6 their is a=
lso
> a route.c with some nice formula in it, the formula says exactly the
> following:
> net->ipv6.sysctl.ip6_rt_max_size =3D 4096;
>=20
> The result of all this magic was that when the BGP RIB in my quagga
> routers went over the 4096 routes, quagga started complaining that it
> couldn't put the routes in the kernel FIB anymore and this went all i=
nto
> syslog.
>=20
> It took some digging to find the reason for these error messages, but
> after changing this sysctl to something more useful, everything was f=
ine
> again.
>=20
> Maybe it is a good idea to change this in the IPv6 tree to something
> more useful in the same direction of the solution that is in the IPv4=
 tree.
>=20

Hi

IPv4 does an auto memsize tuning because it uses a hash table, and this
table cant be resized after boot.

IPv6 is different, and you can change=20
/proc/sys/net/ipv6/route/gc_thresh & /proc/sys/net/ipv6/route/max_size
whithout downsides.

echo 32768 >/proc/sys/net/ipv6/route/max_size
echo 8192 >/proc/sys/net/ipv6/route/gc_thresh

(or equivalent lines in /etc/sysctl.conf)

We probably could change default values, but they are "not hardcoded" ;=
)



