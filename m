From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Wed, 23 Jan 2013 15:26:42 -0800
Message-ID: <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
References: <20130123161238.GE8912@reaktio.net>
	<20130123214445.GA16641@order.stressinduktion.org>
	<20130123215151.GF8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pasi =?ISO-8859-1?B?S+Rya2vkaW5lbg==?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:55531 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab3AWX0s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 18:26:48 -0500
Received: by mail-pb0-f54.google.com with SMTP id rr4so3125494pbb.13
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 15:26:48 -0800 (PST)
In-Reply-To: <20130123215151.GF8912@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jan 2013 23:51:51 +0200
Pasi K=E4rkk=E4inen <pasik@iki.fi> wrote:

> On Wed, Jan 23, 2013 at 10:44:45PM +0100, Hannes Frederic Sowa wrote:
> > On Wed, Jan 23, 2013 at 06:12:38PM +0200, Pasi K=E4rkk=E4inen wrote=
:
> > > My laptop running Fedora 17 randomly crashes when using wfica (Ci=
trix Receiver / ICA Client)=20
> > > proprietary closed source client for accessing remote desktop ser=
ver.=20
> > > wfica is running as a normal user, so it shouldn't be able to cau=
se a kernel crash.=20
> > >=20
> > > Crashes seem to happen most often when I use either wlan- or 3G m=
obile data Internet connection.=20
> > > These kernel crashes happen ramdomly, often 1-2 times a week.=20
> > > What usually happens is that I notice the Internet connection has=
 died,=20
> > > and when I check the kernel dmesg I'm seeing the traceback.=20
> > > At this point I'm still able to use the gnome desktop for maybe 1=
-5 minutes,=20
> > > but applications start to fail one by one, and finally everything=
 just halts=20
> > > and I need to power cycle the laptop.=20
> >=20
> > Would it be possible to capture a strace -e network, so we could se=
e which
> > setsockopt combinations are being applied to the socket. Is capturi=
ng ss -ioem
> > in such moments still possible?
> >=20
>=20
> I don't think I'm able to strace or anything at that point..=20
> It took me at least 10 tries (=3Dcrashes) before I was able to "dmesg=
 > log.txt" successfully ..=20
> (usually writing/redirecting to a file fails because the disk/fs is a=
lready unavailable..)
>=20
> I can always try though!
>=20
> Any other ideas?=20

I see no problems when using Citrix.
This is a normal strace of the program wifca (in idle loop)


select(0, NULL, NULL, NULL, {0, 9902})  =3D 0 (Timeout)
setsockopt(11, SOL_SOCKET, SO_ERROR, [11], 4) =3D -1 ENOPROTOOPT (Proto=
col not available)
gettimeofday({1358983243, 665428}, NULL) =3D 0
gettimeofday({1358983243, 665750}, NULL) =3D 0
read(4, 0x84a59a0, 4096)                =3D -1 EAGAIN (Resource tempora=
rily unavailable)
read(4, 0x84a59a0, 4096)                =3D -1 EAGAIN (Resource tempora=
rily unavailable)
gettimeofday({1358983243, 666322}, NULL) =3D 0
poll([{fd=3D5, events=3DPOLLIN}, {fd=3D4, events=3DPOLLIN}, {fd=3D11, e=
vents=3DPOLLIN}], 3, 88) =3D 0 (Timeout)
gettimeofday({1358983243, 754766}, NULL) =3D 0
gettimeofday({1358983243, 754964}, NULL) =3D 0
gettimeofday({1358983243, 755152}, NULL) =3D 0

Not the smartest program, on the block.

Here is what it looks like when getting data.

poll([{fd=3D5, events=3DPOLLIN}, {fd=3D4, events=3DPOLLIN}, {fd=3D11, e=
vents=3DPOLLIN}], 3, 88) =3D 1 ([{fd=3D4, revents=3DPOLLIN}])
read(4, "\7\3=3D.\202\2135\6\315\0\0\0\326\0`\3\0\0\0\0]\5/\2\347\4\24\=
2\20\0\0\2"..., 4096) =3D 96
read(4, 0x84a59a0, 4096)                =3D -1 EAGAIN (Resource tempora=
rily unavailable)
gettimeofday({1358983244, 918078}, NULL) =3D 0
gettimeofday({1358983244, 918303}, NULL) =3D 0
gettimeofday({1358983244, 918512}, NULL) =3D 0
gettimeofday({1358983244, 918666}, NULL) =3D 0
gettimeofday({1358983244, 918786}, NULL) =3D 0
send(11, "\27\3\1\0000q%\313\247\260\372\322\217\2272\362\270\242\215J\=
275\217IW=3D5\355\235@\0\365\211"..., 53, 0) =3D 53
gettimeofday({1358983244, 919012}, NULL) =3D 0
poll([{fd=3D4, events=3DPOLLIN|POLLOUT}], 1, 4294967295) =3D 1 ([{fd=3D=
4, revents=3DPOLLOUT}])
writev(4, [{"\30\0\6\0\234\0`\3\1\0\0\0s\1\0\0s\1\0\0\202\2135\6f\0\5\0=
\16\0\0\0"..., 44}, {NULL, 0}, {"", 0}], 3) =3D 44
read(4, 0x84a59a0, 4096)                =3D -1 EAGAIN (Resource tempora=
rily unavailable)
read(4, 0x84a59a0, 4096)                =3D -1 EAGAIN (Resource tempora=
rily unavailable)
gettimeofday({1358983244, 919542}, NULL) =3D 0
