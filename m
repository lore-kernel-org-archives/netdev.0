From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_BINDTODEVICE and IP_TRANSPARENT (TPROXY)
Date: Wed, 02 Dec 2009 05:56:51 +0100
Message-ID: <4B15F393.5030808@gmail.com>
References: <fd1a5ee40911301515y7d5e9f8fq62ff3e28b747c308@mail.gmail.com> <fd1a5ee40912011718r60487ce0obd88c2fbdb55fa15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tproxy@lists.balabit.hu
To: Ashwani Wason <ashwas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55138 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbZLBE4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 23:56:47 -0500
In-Reply-To: <fd1a5ee40912011718r60487ce0obd88c2fbdb55fa15@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ashwani Wason a =E9crit :
> After debugging a bit into how nf_tproxy_get_sock_v4() looks up a
> listener for foreign connections using __inet_lookup_listener() and
> compute_score() I found that the problem was happening because of the
> way I had the TPROXY rules setup. Those rules work if the proxy has a
> single listening socket for INADDR_ANY. If multiple listening sockets
> must be used, one for each local address, which is the case for using
> SO_BINDTODEVICE then the TPROXY rules must also be "fully qualified"
> (with interface name [-i] and IP address thereof [--on-ip]). So the
> rules in my example change as follows...
>=20
> Instead of using:
>=20
>> iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY --tprox=
y-mark 0x1/0x1 --on-port 4002
>=20
> Use:
>=20
> iptables -t mangle -A PREROUTING *-i eth0* -p tcp --dport 80 -j TPROX=
Y
> --tproxy-mark 0x1/0x1 *--on-ip 192.168.0.65* --on-port 4002
> iptables -t mangle -A PREROUTING *-i eth1* -p tcp --dport 80 -j TPROX=
Y
> --tproxy-mark 0x1/0x1 *--on-ip 192.168.1.65* --on-port 4002
>=20
> With these rules the listening socket was looked up correctly and the
> sk_bound_dev_if of the socket was honored.
>=20
> - Ashwani
>=20
> PS: Sorry to anyone (Jamal) who already spent any time on this.
> PPS: Copying the tproxy list in case someone else is looking for this
> stuff in the future.

Thanks a lot for sharing your discoveries :)

