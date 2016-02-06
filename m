From: =?utf-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Subject: Reply: [net] bonding: use return instead of goto
Date: Sat, 6 Feb 2016 19:05:40 +0800
Message-ID: <000001d160ce$52b81420$f8283c60$@cmss.chinamobile.com>
References: <000301d15fb6$77bf08f0$673d1ad0$@cmss.chinamobile.com> <20160205212438.GC63431@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <j.vosburgh@gmail.com>, <netdev@vger.kernel.org>
To: "'Jarod Wilson'" <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3940 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbcBFLFh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 06:05:37 -0500
In-Reply-To: <20160205212438.GC63431@redhat.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, Feb 05, 2016 at 09:42:24AM +0800, =E5=BC=A0=E8=83=9C=E4=B8=BE=
 wrote:
> > > On Wed, Feb 03, 2016 at 06:15:22AM +0000, Zhang Shengju wrote:
> > > > Replace 'goto' with 'return' to remove unnecessary check at lab=
el:
> > > > err_undo_flags.
> > >
> > > I think you're going to have to explain how you came to the
> > > conclusion that the check isn't necessary.
> ...
> > The reason is that 'err_undo_flags' do two things for the first sla=
ve
> > device:
> > 1. revert bond mac address if it is set by the slave device.
> > 2. revert bond device type if it's not ARPHRD_ETHER.
> >
> > I think it's not necessary for the three places, they changed neith=
er
> > bond mac address nor type.
> > it's straightforward to return directly.
>=20
> I see what you're saying, and that does look to be true if you're onl=
y adding a
> singular first device right now. But looking at the enslave and relea=
se paths, I
> don't see anything preventing concurrent slave adds and removes, whic=
h
> could mean there are situations where those checks really are necessa=
ry. I
> don't actually know.
>=20
> --
> Jarod Wilson
> jarod@redhat.com

All of three places don't change any attributes of bond device,=20
just for sanity check before enslaving. =20
If it's necessary for these three places to goto 'err_undo_flags', =20
it will mean that all sanity checks before these three places need to d=
o so, which is not right clearly.=20

Even there is concurrent situation which make the check necessary, whic=
h I haven't figure out yet,
it's not right place to do this. =20

Thanks,
Shengju
