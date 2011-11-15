From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Tue, 15 Nov 2011 22:09:15 +0100
Message-ID: <1321391355.2602.0.camel@edumazet-laptop>
References: <4EC2CA52.6020104@icdsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ivan Zahariev <famzah@icdsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37395 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351Ab1KOVJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:09:19 -0500
Received: by wyh15 with SMTP id 15so7555924wyh.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 13:09:18 -0800 (PST)
In-Reply-To: <4EC2CA52.6020104@icdsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 novembre 2011 =C3=A0 22:23 +0200, Ivan Zahariev a =C3=A9cri=
t :
> Hello,
>=20
> We have changed nothing in our network infrastructure but only upgrad=
ed=20
> from Linux kernel 2.6.36.2 to 3.0.3. Here is the problem we are=20
> experiencing:
>=20
> ICMP redirected routes are cached forever, and they can be cleared on=
ly=20
> by a reboot.
>=20
> Here is an example:
>=20
> root@machine5:~# ip route get 1.1.1.1
> 1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
>      cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10
>=20
> root@machine5:~# ip route list cache match 1.1.1.1
> 1.1.1.1 tos lowdelay via 9.0.0.1 dev eth0  src 5.5.5.5
>      cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10
> 1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
>      cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10
> ...(two more entries, all go via 9.0.0.1)...
>=20
> 1.1.1.1 is the test destination address
> 5.5.5.5 is the source IP address of "machine5" via dev eth0, the only=
=20
> interface besides "lo"
> 9.0.0.1 is the incorrect gateway which we were redirected to; we want=
 to=20
> change the route to 9.0.0.8
>=20
> I found no way to clear this route. What I tried:
>=20
> root@machine5:~# ip route flush cache ### CACHE FLUSH ###
> root@machine5:~# ip route list cache match 1.1.1.1 # empty
>=20
> root@machine5:~# ip route flush cache ### CACHE FLUSH ###
> root@machine5:~# echo 1 > /proc/sys/net/ipv4/route/flush
> root@machine5:~# ip route list cache match 1.1.1.1 # empty
>=20
> root@machine5:~# ip route get 1.1.1.1 # magically re-inserts the=20
> <redirected> route, tcpdump sees NO ICMP traffic
> 1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
>      cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10
>=20
> I also tried to force a scheduled route flush:
>=20
> root@machine5:~# echo 1 > /proc/sys/net/ipv4/route/gc_timeout
> root@machine5:~# echo 1 > /proc/sys/net/ipv4/route/gc_interval
>=20
> A reboot fixed it all.
>=20
> This may be related to the "Several major changes to our routing=20
> infrastructure" (https://lkml.org/lkml/2011/3/16/384).
> Other users are reporting the same problem:
> * https://plus.google.com/u/0/117161704068825702652/posts/1UK1Rp4KA4J
> * http://lists.debian.org/debian-kernel/2011/10/msg00633.html
> Other similar issues:
> * http://www.spinics.net/lists/netdev/msg176966.html
> * http://forums.gentoo.org/viewtopic-t-901024-start-0.html
>=20
> This has been occurring on a few KVM guest machines and also on a=20
> regular Linux machine, so it's not KVM related.
>=20
> Is this a bug, or it's me who's missing something?
>=20

It is a bug, and as such could you provide needed information for us to
reproduce it ?

What is your network setup ?
