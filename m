From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: System blocks (hangs) on ifconfig up
Date: Sun, 12 Dec 2010 21:53:54 +0100
Message-ID: <1292187234.18698.7.camel@edumazet-laptop>
References: <4D04E57C.7020509@trego.co.il>
	 <1292185786.18698.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Shmulik Hen <shmulik@trego.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54145 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab0LLUx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 15:53:59 -0500
Received: by wwa36 with SMTP id 36so5661638wwa.1
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 12:53:58 -0800 (PST)
In-Reply-To: <1292185786.18698.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 12 d=C3=A9cembre 2010 =C3=A0 21:29 +0100, Eric Dumazet a =C3=
=A9crit :
> Le dimanche 12 d=C3=A9cembre 2010 =C3=A0 17:08 +0200, Shmulik Hen a =C3=
=A9crit :
> > Hello,
> >=20
> > My system is Ubuntu 10.04, running kernel 2.6.32-26-generic.
> >=20
> > Whenever I try to bring up a specific ethernet interface for the se=
cond=20
> > time, my
> > system becomes unresponsive for 60 seconds - i.e. no mouse, no keyb=
oard, no
> > screen refresh. etc.
> >=20
> > Looking at the driver's code, I could see that it's dev->open() met=
hod=20
> > calls
> > wait_event_interruptible_timeout() with a timeout of 60 seconds - e=
xactly
> > the delay I'm seeing.
> >=20
>=20
> What is this driver ?
>=20
> > I have narrowed the code to a bare minimum (see below - loosely bas=
ed on
> > dummy.c), which only calls mdelay(10000) in it's dev->open() method=
, and
> > still, my system blocks for exactly 10 seconds when I run the follo=
wing
> > sequence:
> >=20
> >  > sudo ifconfig shmulik0 up
> >  > sudo ifconfig shmulik0 down
> >  > sudo ifconfig shmulik0 up
> >=20
> > At this point - the system is stuck for 10 seconds.
> >=20
>=20
> Certainly not "stuck for 10 seconds"
>=20
> mdelay(10000) suspends this task for 10 seconds, but other tasks can
> certainly run.
>=20
> However, your shell waits that "ifconfig ... up" finishes.
>=20
>=20

Oops, I forgot mdelay() was a spin primitive, but was misleading by you=
r
wait_event_interruptible_timeout() previous reference.

Doing mdelay(10000) is certainly very lazy, I hope no driver does
that ...



