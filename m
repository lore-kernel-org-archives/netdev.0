From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 18:31:24 +0100
Message-ID: <1329845484.18384.20.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <5196304.nDv69tPK8W@localhost.localdomain>
	 <1329842751.18384.10.camel@edumazet-laptop>
	 <2604639.CVkfrWv5sk@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37074 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab2BURbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:31:32 -0500
Received: by werb13 with SMTP id b13so3958366wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:31:31 -0800 (PST)
In-Reply-To: <2604639.CVkfrWv5sk@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 19:19 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :
> Download speed from ftp3.de.freebsd.org increases from 5 MB/s to 10 M=
B/s
> after I set "sysctl net.ipv4.tcp_rmem=3D"4096 87380 4127616""" in 3.2=
=2E7 kernel.
>=20
> --2012-02-21 18:56:36--  ftp://ftp3.de.freebsd.org/pub/FreeBSD/ISO-IM=
AGES-i386/8.2/FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz
> 100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>] 2 066 424 512 10,3M/=
s  in 3m 17s
> 2012-02-21 18:59:56 (9,99 MB/s) - =C2=AB/dev/null=C2=BB saved [206642=
4512]
>=20

Yep, this confirms the thing. You were at the limit of optimal receiver
window. Find a more remote server (80ms rtt for example) and you'll see
that your default tcp_rmem[2] was too small, even on 3.1.10 kernel.

> But maximum speed in 3.1.10 kernel (without this sysctl settings) sti=
ll
> a bit more than in 3.2.7 - 11 MB/s instead of 10.3 MB/s.
>=20
> --2012-02-21 18:56:36--  ftp://ftp3.de.freebsd.org/pub/FreeBSD/ISO-IM=
AGES-i386/8.2/FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz
> 100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>] 2 066 424 512 11,0M/=
s   in 3m 30s  =20
> 2012-02-21 19:13:55 (9,39 MB/s) - =C2=AB/dev/null=C2=BB saved [206642=
4512]

Thats one measure, you'll have to make a lot of different measures to
make this significant, preferably in a lab to rule out different
external network conditions.
