From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT question
Date: Wed, 25 Jan 2012 17:52:07 +0100
Message-ID: <1327510327.2425.75.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F2025BD.20903@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53881 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755740Ab2AYQwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 11:52:11 -0500
Received: by bkas6 with SMTP id s6so4581452bka.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 08:52:09 -0800 (PST)
In-Reply-To: <4F2025BD.20903@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 10:54 -0500, Stephen Clark a =C3=A9c=
rit :
> Can iptables do a network to network nat without having to write out =
a=20
> bunch of nat rules.
> In other words translate  192.168.198.0/24 to 172.16.10.0/24 without=20
> having to write out
> 256 rules.
>=20
> Also can iptables handle 1000 nat rules like above if they have to be=
=20
> written out on
> a 1.66ghz intel dual core atom with 1gb of mem.
>=20
> I know this isn't appropriate question for devel list but I didn't fi=
nd=20
> anything googling.
>=20
> Thanks,
>=20

If you are forced to use 256 rules, you could split them into 16 tables
of 16 rules and do a hash split.

Since these rules are run only for new connections, it might be OK
performance wise, depending on rate of connection establishment.

If not, you can try NETMAP :)

# iptables -t nat -A POSTROUTING -s 192.168.198.0/24 -j NETMAP --to 172=
=2E16.10.0/24

# iptables -t nat -nvL POSTROUTING
Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               des=
tination        =20
    0     0 NETMAP     all  --  *      *       192.168.198.0/24     0.0=
=2E0.0/0           172.16.10.0/24
