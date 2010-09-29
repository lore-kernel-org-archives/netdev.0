From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Wed, 29 Sep 2010 23:45:21 +0200
Message-ID: <1285796721.5211.156.camel@edumazet-laptop>
References: <20100929191851.GC86786@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Vlasov <renton@renton.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62710 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755362Ab0I2Vp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 17:45:27 -0400
In-Reply-To: <20100929191851.GC86786@beaver.vrungel.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 23:18 +0400, Alexey Vlasov a =C3=A9=
crit :=20
> Hi.
>=20
> I'm not sure actually that I should write here, may be I should ask i=
n
> netfilter maillist, but if is something wrong please correct me.
>=20

CC netdev


> I've got rather large linux shared hosting, and on my new servers I
> noticed some strange singularity, that this simple rule:
>=20
> # iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags
> FIN,SYN,RST,ACK SYN -j LOG --log-prefix "ipsec:SYN-OUTPUT "
> --log-uid
>=20
> gives essential time delays simply at ping from the adjacent server
> on a local area network. I don't know precisely what's wrong whether =
the
> reason is in the bad support by a kernel of new hardware, or it conce=
rns
> generally the new kernel, but now it leads to the situation that even=
 at simple
> DDOS attacks to client sites, it becomes difficult to make something,=
 and in
> general all works only worse.
>=20
> It seems to me that with the increase of CPU cores' amount, it only b=
ecomes
> worse and worse, and, obviously, iptables uses resources of only one =
processor,
> which resources to it for any reason doesn't suffice.
>=20

Its not true. iptables can run on all cpus in //

> newbox # iptables -F
> otherbox # ping -c 100 newbox
> ...
> 100 packets transmitted, 100 received, 0% packet loss, time 100044ms
> rtt min/avg/max/mdev =3D 0.133/2.637/17.172/3.736 ms
>=20
> OK.
>=20
> newbox # iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,=
SYN,RST,ACK SYN
> -j LOG --log-prefix "ipsec:SYN-OUTPUT " --log-uid
> otherbox # ping -c 100 newbox
> ...
> 64 bytes from (newbox): icmp_seq=3D3 ttl=3D64 time=3D1.58 ms
> 64 bytes from (newbox): icmp_seq=3D4 ttl=3D64 time=3D98.7 ms
> 64 bytes from (newbox): icmp_seq=3D5 ttl=3D64 time=3D18.2 ms
> 64 bytes from (newbox): icmp_seq=3D6 ttl=3D64 time=3D6.13 ms
> 64 bytes from (newbox): icmp_seq=3D7 ttl=3D64 time=3D108 ms
> ...
> 64 bytes from (newbox): icmp_seq=3D55 ttl=3D64 time=3D2.30 ms
> 64 bytes from (newbox): icmp_seq=3D56 ttl=3D64 time=3D59.9 ms
> 64 bytes from (newbox): icmp_seq=3D57 ttl=3D64 time=3D0.155 ms
> ...
> 64 bytes from (newbox): icmp_seq=3D61 ttl=3D64 time=3D13.4 ms
> 64 bytes from (newbox): icmp_seq=3D62 ttl=3D64 time=3D55.0 ms
> 64 bytes from (newbox): icmp_seq=3D63 ttl=3D64 time=3D0.233 ms
> ...
> 100 packets transmitted, 100 received, 0% packet loss, time 99957ms
> rtt min/avg/max/mdev =3D 0.111/7.519/108.061/18.478 ms
>=20
> newbox # iptables -L -v -n
> Chain INPUT (policy ACCEPT 346K packets, 213M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>=20
> Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>=20
> Chain OUTPUT (policy ACCEPT 296K packets, 290M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>   234 14040 LOG        tcp  --  *      *       0.0.0.0/0            0=
=2E0.0.0/0   =20
> tcp dpt:80 flags:0x17/0x02 LOG flags 8 level 4 prefix `ipsec:SYN-OUTP=
UT- '
>=20
> My old server: Intel SR1500, Xeon 5430, kernel 2.6.24 - 2.6.28
> Newbox: SR1620UR, 5650, kernel 2.6.32
>=20
> Thanks in advance.
>=20

Seems strange indeed, since the LOG you add should not slowdown icmp
trafic that much.

But if you send SYN packets in the same time, (logged), this might slow
down the reception (and answers) of ICMP frames. LOG target can be quit=
e
expensive...=20

Is using other rules gives same problem ?

iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK=
 SYN
iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK=
 SYN
iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK=
 SYN
iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags FIN,SYN,RST,ACK=
 SYN





