From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more
 per-cpu memory?
Date: Mon, 08 Nov 2010 18:55:12 +0100
Message-ID: <1289238912.3167.4.camel@edumazet-laptop>
References: <4CD43C87.5040403@candelatech.com>
	 <1288980361.2882.1070.camel@edumazet-laptop>
	 <4CD449A5.5070305@candelatech.com>
	 <1288988403.2665.268.camel@edumazet-laptop>
	 <1288995103.2665.653.camel@edumazet-laptop>
	 <4CD49C2F.3060904@candelatech.com>
	 <1289028392.2665.2418.camel@edumazet-laptop>
	 <4CD58B9C.2030006@candelatech.com>
	 <1289214131.2820.187.camel@edumazet-laptop>
	 <4CD83752.1070501@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61903 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab0KHRzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 12:55:17 -0500
In-Reply-To: <4CD83752.1070501@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 09:45 -0800, Ben Greear a =C3=A9crit :

> That helps.  I'm getting all of the IP addrs set now, but
> having trouble with some of the default gateways (I have one
> routing table per interface).
>=20
> ./local/sbin/ip -6 route replace default via 2002:9:8::1 dev eth7#458=
 table 726
> RTNETLINK answers: No buffer space available
>=20
> dmesg is full of this:
>=20
> [247106.294743] ipv6: Neighbour table overflow.
>=20
>=20
> A quick look in /proc didn't show a tunable for this, but I'll
> go grub through the code.
>=20
> As for the route/max_size, it would be nice to see some useful kernel
> message in dmesg when this hit.  Just telling the user '-ENOMEM'
> is not at all sufficient to help them figure out the problem.

Sure, patches are welcomed. Apparently nobody yet used ipv6 with so man=
y
devices / routes, and this nobody contributed to extend limits.

>=20
> For that matter, why is there such a limit anyway?  IPv4 doesn't appe=
ar
> to have any such limit?

There are limits for ipv4, much bigger, you probably never noticed.


/proc/sys/net/ipv4/route/gc_elasticity:8
/proc/sys/net/ipv4/route/gc_interval:60
/proc/sys/net/ipv4/route/gc_min_interval:0
/proc/sys/net/ipv4/route/gc_min_interval_ms:500
/proc/sys/net/ipv4/route/gc_thresh:131072
/proc/sys/net/ipv4/route/gc_timeout:300
/proc/sys/net/ipv4/route/max_size:2097152    <<< HERE
/proc/sys/net/ipv4/route/min_adv_mss:256
/proc/sys/net/ipv4/route/min_pmtu:552
/proc/sys/net/ipv4/route/mtu_expires:600
/proc/sys/net/ipv4/route/redirect_load:2
/proc/sys/net/ipv4/route/redirect_number:9
/proc/sys/net/ipv4/route/redirect_silence:2048

I suggest followup discussion can got to netdev only, now per-cpu it no=
t
anymore the problem ?




