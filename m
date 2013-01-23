From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid
 with wfica
Date: Wed, 23 Jan 2013 14:25:44 -0800
Message-ID: <1358979944.12374.1143.camel@edumazet-glaptop>
References: <20130123161238.GE8912@reaktio.net>
	 <20130123214445.GA16641@order.stressinduktion.org>
	 <20130123215151.GF8912@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:39953 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab3AWWZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 17:25:46 -0500
Received: by mail-pb0-f51.google.com with SMTP id ro12so4971302pbb.10
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:25:46 -0800 (PST)
In-Reply-To: <20130123215151.GF8912@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 23:51 +0200, Pasi K=C3=A4rkk=C3=A4inen wrote:
> On Wed, Jan 23, 2013 at 10:44:45PM +0100, Hannes Frederic Sowa wrote:
> > On Wed, Jan 23, 2013 at 06:12:38PM +0200, Pasi K=C3=A4rkk=C3=A4inen=
 wrote:
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
> Any other ideas?

Something sets tp->snd_cwnd to 0, and thats a bug.
