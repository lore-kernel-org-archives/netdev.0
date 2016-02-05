From: Jarod Wilson <jarod@redhat.com>
Subject: Re: Reply: [net] bonding: use return instead of goto
Date: Fri, 5 Feb 2016 16:24:39 -0500
Message-ID: <20160205212438.GC63431@redhat.com>
References: <000301d15fb6$77bf08f0$673d1ad0$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: j.vosburgh@gmail.com, netdev@vger.kernel.org
To: =?utf-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750829AbcBEVYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 16:24:40 -0500
Content-Disposition: inline
In-Reply-To: <000301d15fb6$77bf08f0$673d1ad0$@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 05, 2016 at 09:42:24AM +0800, =E5=BC=A0=E8=83=9C=E4=B8=BE w=
rote:
> > On Wed, Feb 03, 2016 at 06:15:22AM +0000, Zhang Shengju wrote:
> > > Replace 'goto' with 'return' to remove unnecessary check at label=
:
> > > err_undo_flags.
> >=20
> > I think you're going to have to explain how you came to the conclus=
ion
> > that the check isn't necessary.
=2E..
> The reason is that 'err_undo_flags' do two things for the first slave
> device:
> 1. revert bond mac address if it is set by the slave device.
> 2. revert bond device type if it's not ARPHRD_ETHER.
>=20
> I think it's not necessary for the three places, they changed neither=
  bond
> mac address nor type.=20
> it's straightforward to return directly.

I see what you're saying, and that does look to be true if you're only
adding a singular first device right now. But looking at the enslave an=
d
release paths, I don't see anything preventing concurrent slave adds an=
d
removes, which could mean there are situations where those checks reall=
y
are necessary. I don't actually know.

--=20
Jarod Wilson
jarod@redhat.com
