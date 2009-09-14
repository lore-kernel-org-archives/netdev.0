From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Mon, 14 Sep 2009 15:57:03 +0200
Message-ID: <4AAE4BAF.2010406@gmail.com>
References: <20090914150935.cc895a3c.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephan von Krawczynski <skraw@ithnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50915 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbZINN5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 09:57:06 -0400
In-Reply-To: <20090914150935.cc895a3c.skraw@ithnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan von Krawczynski a =E9crit :
> Hello all,
>=20
> today we experienced some sort of regression in 2.6.31 ipv4 implement=
ation, or
> at least some incompatibility with former 2.6.30.X kernels.
>=20
> We have the following situation:
>=20
>                                        ---------- vlan1@eth0 192.168.=
2.1/24
>                                       /
> host A 192.168.1.1/24 eth0  -------<router>            host B
>                                       \
>                                        ---------- eth1 192.168.3.1/24
>=20
>=20
> Now, if you route 192.168.1.0/24 via interface vlan1@eth0 on host B a=
nd let
> host A ping 192.168.2.1 everything works. But if you route 192.168.1.=
0/24 via
> interface eth1 on host B and let host A ping 192.168.2.1 you get no r=
eply.
> With tcpdump we see the icmp packets arrive at vlan1@eth0, but no icm=
p echo
> reply being generated neither on vlan1 nor eth1.
> Kernels 2.6.30.X and below do not show this behaviour.
> Is this intended? Do we need to reconfigure something to restore the =
old
> behaviour?
>=20

Asymetric routing ?

Check your rp_filter settings

grep . `find /proc/sys/net -name rp_filter`

rp_filter - INTEGER
        0 - No source validation.
        1 - Strict mode as defined in RFC3704 Strict Reverse Path
            Each incoming packet is tested against the FIB and if the i=
nterface
            is not the best reverse path the packet check will fail.
            By default failed packets are discarded.
        2 - Loose mode as defined in RFC3704 Loose Reverse Path
            Each incoming packet's source address is also tested agains=
t the FIB
            and if the source address is not reachable via any interfac=
e
            the packet check will fail.

        Current recommended practice in RFC3704 is to enable strict mod=
e
        to prevent IP spoofing from DDos attacks. If using asymmetric r=
outing
        or other complicated routing, then loose mode is recommended.

        conf/all/rp_filter must also be set to non-zero to do source va=
lidation
        on the interface

        Default value is 0. Note that some distributions enable it
        in startup scripts.


