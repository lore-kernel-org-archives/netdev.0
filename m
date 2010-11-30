From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Net-ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Tue, 30 Nov 2010 18:48:36 +0900
Message-ID: <20101130094836.GA26315@verge.net.au>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34359 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab0K3Jsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 04:48:39 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 12:00:29AM -0800, Mahesh Bandewar wrote:
> This patch enables ethtool to set the loopback mode on a given
> interface. This is the reworked version of earlier submit (which I
> don't have reference to). By configuring the interface in loopback
> mode in conjunction with a policy route / rule, a userland applicatio=
n
> can stress the egress / ingress path exposing the flows of the change
> in progress and potentially help developer(s) understand the impact o=
f
> those changes without even sending a packet out on the network.
>=20
> Following set of commands illustrates one such example -
> =C2=A0=C2=A0 =C2=A0a)=C2=A0ifconfig eth1 192.168.1.1

         Given that b) and c) use ip it seems to me that it would
	 make sense to use i for a) too.=20

	 ip addr add 192.168.1.1/24 dev eth1

> =C2=A0=C2=A0 =C2=A0b)=C2=A0ip -4 rule add from all iif eth1 lookup 25=
0
> =C2=A0=C2=A0 =C2=A0c)=C2=A0ip -4 route add local 0/0 dev lo proto ker=
nel scope host table 250
> =C2=A0=C2=A0 =C2=A0d) arp -Ds 192.168.1.100 eth1
> =C2=A0=C2=A0 =C2=A0e)=C2=A0arp -Ds 192.168.1.200 eth1
> =C2=A0=C2=A0 =C2=A0f)=C2=A0sysctl -w net.ipv4.ip_nonlocal_bind=3D1
> =C2=A0=C2=A0 =C2=A0g)=C2=A0sysctl -w net.ipv4.conf.all.accept_local=3D=
1
> =C2=A0=C2=A0 =C2=A0# Assuming that the machine has 8 cores
> =C2=A0=C2=A0 =C2=A0h) taskset 000f netserver -L 192.168.1.200
> =C2=A0=C2=A0 =C2=A0i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.10=
0 -H 192.168.1.200 -l 30
