From: =?iso-8859-1?Q?Pommnitz_J=F6rg?= <Pommnitz@iabg.de>
Subject: AW: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18/4.6.4
Date: Thu, 21 Jul 2016 16:00:24 +0000
Message-ID: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEC9A@ExMbx1.iabg.de>
References: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEC70@ExMbx1.iabg.de>
 <AM4PR0501MB1940C0DFCF936A7957D88971DB090@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ilan Tayari <ilant@mellanox.com>,
	Shanker Wang <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.iabg.de ([84.11.16.20]:39296 "EHLO mail1.iabg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbcGUQGO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 12:06:14 -0400
In-Reply-To: <AM4PR0501MB1940C0DFCF936A7957D88971DB090@AM4PR0501MB1940.eurprd05.prod.outlook.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm tracking this down and I *think* I found it. I think it's not reall=
y an IPsec issue.
Something changed between 2.6.x and 3.x regarding the handling of multi=
cast packets. If
I call "iperf -s -u -V -B ff0e::1" and those join ff0e::1, things start=
 to work.

Regards
  joerg

> -----Urspr=FCngliche Nachricht-----
> Von: Ilan Tayari [mailto:ilant@mellanox.com]
> Gesendet: Donnerstag, 21. Juli 2016 16:41
> An: Pommnitz J=F6rg; Shanker Wang
> Cc: netdev@vger.kernel.org
> Betreff: RE: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18/4=
=2E6.4
>
> > Node 1: fd01:1b10:1000::1 is running 4.6.4
> > 14:21:50.737092 IP6 fd01:1b10:1000::3 > ff0e::1:
> > ESP(spi=3D0x00000001,seq=3D0x100), length 136
> > 14:21:51.737155 IP6 fd01:1b10:1000::3 > ff0e::1:
> > ESP(spi=3D0x00000001,seq=3D0x101), length 136
> ...
> > ip -s xfrm state
> > src fd01:1b10:1000::1 dst ff0e::1
> >         proto esp spi 0x00000001(1) reqid 0(0x00000000) mode tunnel
> ...
> >           add 2016-07-21 14:18:08 use -
> ...
> >         dir out ...
> ...
> >           add 2016-07-21 14:18:08 use -
> ...
> >         dir fwd ...
> >           add 2016-07-21 14:18:08 use -
> ...
> >         dir in ...
> >           add 2016-07-21 14:18:08 use -
>
> Hi Joerg,
>
> See the "use -" instead of a date/time of last usage (like in your ou=
tput
> from 2.6) Packets are received, but nothing is matched to your xfrm s=
tates
> and policies.
>
> Are you sure this is the full output of "ip -s xfrm policy"? I feel l=
ike
> something is missing.
>
> At first glance I'd say it looks like src+dst doesn't match the packe=
ts.
> Packet source-ip is ::3, while xfrm-state source ip matches::1
>
> Ilan.

________________________________
Industrieanlagen-Betriebsgesellschaft mbH

Sitz der Gesellschaft: Ottobrunn, Registergericht: Amtsgericht M=FCnche=
n, HRB 5499
Gesch=E4ftsf=FChrung: Prof. Dr.-Ing. Rudolf F. Schwarz
Vorsitzender des Aufsichtsrats: RA Engelbert Kupka MdL a.D.
