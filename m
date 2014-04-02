From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.14 regression: huge latency in read/select on tun
Date: Wed, 02 Apr 2014 09:42:53 -0700
Message-ID: <1396456973.3989.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <533C381E.9090103@odi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ortwin =?ISO-8859-1?Q?Gl=FCck?= <odi@odi.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54674 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335AbaDBQm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:42:56 -0400
In-Reply-To: <533C381E.9090103@odi.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 18:17 +0200, Ortwin Gl=C3=BCck wrote:
> Hi,
>=20
> Since 3.14 the openconnect VPN tunnel becomes unusable for me because
> packets appear on the tun device at a horribly low rate. 3.12 and 3.1=
3
> do not exhibt the problem.
>=20
> Here is an strace of openconnect trying to read from its fd
>   7 -> /dev/net/tun
>=20
> 15:07:33.130640 read(7, 0x1e05e58, 1280) =3D -1 EAGAIN (Resource
> temporarily unavailable)
> =3D=3D=3D> should return available data already
> 15:07:33.130745 select(8, [3 6 7], [], [6], {30, 0}) =3D 1 (in [7], l=
eft
> {29, 783272})
> =3D=3D=3D> HUGE 217ms delay here
> 15:07:33.347681 read(6, 0x1dfc973, 5)   =3D -1 EAGAIN (Resource
> temporarily unavailable)
> 15:07:33.347806 read(7,
> "E\10\5\0b\343@\0@\6\17~\n\363X\236\n\271UE\222:\0\26\37O\7\342\315\2=
1q\33"...,
> 1280) =3D 1280
>=20
>=20
> The send queue of the socket being routed via the tun device has a lo=
t
> of outstanding data (here an scp/ssh upload):
> tcp        0  29788 local:46577  remote:22   ESTABLISHED
>=20
> (IPs replaced for privacy)
>=20
> toggling TCP autocorking has no influence.
>=20
> Any ideas what could be the culprit?

Nothing else than autocorking comes to mind.

You could post a tcpdump maybe ?

I believe some tools exist to anonymize a pcap file.
