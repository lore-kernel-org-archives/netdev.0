From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 20:53:51 +0200
Message-ID: <2389727.KTsXaHXfF4@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <2604639.CVkfrWv5sk@localhost.localdomain> <1329845484.18384.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35878 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2BUSy0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 13:54:26 -0500
Received: by bkcjm19 with SMTP id jm19so5625282bkc.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 10:54:25 -0800 (PST)
In-Reply-To: <1329845484.18384.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=92=D1=82=D0=BE=D1=80=D0=BD=D0=B8=D0=BA 21 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 18:31:24 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> Le mardi 21 f=C3=A9vrier 2012 =C3=A0 19:19 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> =C3=A9crit :
> > Download speed from ftp3.de.freebsd.org increases from 5 MB/s to 10=
 MB/s
> > after I set "sysctl net.ipv4.tcp_rmem=3D"4096 87380 4127616""" in 3=
=2E2.7 kernel.
> >=20
> > --2012-02-21 18:56:36--  ftp://ftp3.de.freebsd.org/pub/FreeBSD/ISO-=
IMAGES-i386/8.2/FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz
> > 100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>] 2 066 424 512 10,=
3M/s  in 3m 17s
> > 2012-02-21 18:59:56 (9,99 MB/s) - =C2=AB/dev/null=C2=BB saved [2066=
424512]
>=20
> Yep, this confirms the thing. You were at the limit of optimal receiv=
er
> window. Find a more remote server (80ms rtt for example) and you'll s=
ee
> that your default tcp_rmem[2] was too small, even on 3.1.10 kernel.

I confirm that 3.1.10 kernel also have similar problems with speed.
Download speed from dl.fedoraproject.org(209.132.181.24, rtt 190ms)
increased after I set "sysctl net.ipv4.tcp_rmem=3D"4096 87380 4127616""=
"

If net.ipv4.tcp_rmem =3D 4096 87380 897664 then I have exactly=20
3.5 MB/s speed limitation:

http://img3.imageshack.us/img3/28/netipv4tcprmem409687380.png

--2012-02-21 20:25:10--  http://dl.fedoraproject.org/pub/fedora/linux/r=
eleases/16/Fedora/i386/iso/Fedora-16-i386-DVD.iso
100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D>] 3 806 375 936 3,28M/s   in 20m 45s
2012-02-21 20:45:56 (2,92 MB/s) - =C2=AB/dev/null=C2=BB saved [38063759=
36/3806375936]

But if net.ipv4.tcp_rmem =3D 4096 87380 4127616 no such limitation,
download speed vary in some ranges but it can be larger than 3,5 MB/s:

http://img27.imageshack.us/img27/28/netipv4tcprmem409687380.png

--2012-02-21 20:09:56--  http://dl.fedoraproject.org/pub/fedora/linux/r=
eleases/16/Fedora/i386/iso/Fedora-16-i386-DVD.iso
00%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D>] 3 806 375 936 4,65M/s   im 13m 3s
2012-02-21 20:22:59 (4,64 MB/s) - =C2=AB/dev/null=C2=BB saved [38063759=
36/3806375936]
