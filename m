From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tc action mirred packet lost
Date: Mon, 01 Nov 2010 12:15:55 +0100
Message-ID: <4CCEA16B.1050603@gmail.com>
References: <aff638d83f21a1b8ab3e1911f2d3ac43@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63486 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab0KALP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 07:15:59 -0400
Received: by wwe15 with SMTP id 15so5903017wwe.1
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 04:15:58 -0700 (PDT)
In-Reply-To: <aff638d83f21a1b8ab3e1911f2d3ac43@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nie=C5=9Bcierowicz Adam wrote:
> Hello,
> recently there was a need to create 3-4 copies of the data sent to th=
e
> router, I decided to use the tc action mirred.
>=20
>=20
> Ingress traficn on eth1 copies to eth1 eth2, eth3, eth4, eth5 using:
> ---
> tc qdisc add dev eth1 ingress
>=20
> tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 match ip =
src
> 0/0 flowid 1:1 action mirred egress mirror dev eth2 pipe action mirre=
d
> egress mirror dev eth3 pipe action mirred egress mirror dev eth4 pipe
> action mirred egress mirror dev eth5
> --=20
>=20
>=20
> Unfortunately the number of packets seen on eth1 qdisc is different t=
han
> the eth [2-5]

Hi,
Usually the reason for such differences is arp or other non-ip
protocols. Try a filter with "protocol all" to check this.

Jarek P.
