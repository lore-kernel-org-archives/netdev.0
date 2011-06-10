From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Fri, 10 Jun 2011 19:17:06 +0200
Message-ID: <1307726226.4044.27.camel@edumazet-laptop>
References: <1307600810.3980.85.camel@edumazet-laptop>
	 <1307664235.17300.44.camel@schen9-DESK>
	 <1307680287.3210.2.camel@edumazet-laptop>
	 <1307725531.17300.58.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38978 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165Ab1FJRRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 13:17:11 -0400
Received: by wwa36 with SMTP id 36so3003321wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 10:17:09 -0700 (PDT)
In-Reply-To: <1307725531.17300.58.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 10:05 -0700, Tim Chen a =C3=A9crit :
> On Fri, 2011-06-10 at 06:31 +0200, Eric Dumazet wrote:
>=20
> >=20
> > Thanks Tim
> >=20
> > I have some questions for further optimizations.
> >=20
> > 1) How many different destinations are used in your stress load ?
> > 2) Could you provide a distribution of the size of packet lengthes =
?
> >    Or maybe the average length would be OK
> >=20
> >=20
> >=20
>=20
> Actually I have one load generator and one server connected to each
> other via a 10Gb link.
>=20
> The server is a 40 core 4 socket Westmere-EX machine and the load
> generator is a 12 core 2 socket Westmere-EP machine.
>=20
> There are 40 memcached daemons on the server each bound to a cpu core
> and listening on a distinctive UDP port.  The load generator has 40
> threads, with each thread sending memcache request to a particular UD=
P
> port.
>=20
>=20
> The load generator's memcache request packet has a UDP payload of 25
> bytes.  The response packet from the daemon has a UDP payload of 13
> bytes.
>=20
> The UPD packets on the load generator and server are distributed acro=
ss
> 16 Tx-Rx queues by hashing on the UDP ports (with slight modification=
 of
> the hash flags of ixgbe).

Excellent, thanks for all these details.

I had the idea some weeks ago to add a fast path to udp_sendmsg() for
small messages [doing the user->kernel copy before RCU route lookup],
that should fit your workload (and other typical UDP workloads)

I'll try to cook patches in next days.

Thanks



