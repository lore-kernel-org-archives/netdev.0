From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: dummy: allocate devices with alloc_netdev_id
Date: Tue, 07 Jun 2011 09:59:52 +0200
Message-ID: <1307433593.3091.3.camel@edumazet-laptop>
References: <1307410786-19110-1-git-send-email-lucian.grijincu@gmail.com>
	 <1307410786-19110-3-git-send-email-lucian.grijincu@gmail.com>
	 <1307416765.2642.37.camel@edumazet-laptop>
	 <BANLkTi=8mHr=SaUacW5cFR5xqXPaxrg5Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64653 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab1FGIBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 04:01:13 -0400
Received: by wwa36 with SMTP id 36so4638109wwa.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2011 01:01:11 -0700 (PDT)
In-Reply-To: <BANLkTi=8mHr=SaUacW5cFR5xqXPaxrg5Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 juin 2011 =C3=A0 10:49 +0300, Lucian Adrian Grijincu a =C3=A9=
crit :
> On Tue, Jun 7, 2011 at 6:19 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le mardi 07 juin 2011 =C3=A0 04:39 +0300, Lucian Adrian Grijincu a =
=C3=A9crit :
> >> The most like case is that no one else is registering devices with=
 a
> >> name like "dummy%d".
> >>
> >> We can bring the complexity down by replacing:
> >> - alloc_netdev_id which is O(N) with
> >> - alloc_netdev_id which, on the average case, is O(1).
> >>
> >> $ time modprobe dummy numdummies=3D5000
> >> - with alloc_netdev   : 9.50s
> >> - with alloc_netdev_id: 3.50s
> >>
> >> NOTE: Stats generated on a heavily patched 3.0-rc1 which replaces =
the
> >>       current O(N^2) sysctl algorithm with a better one.
> >
> > Yes, and disabled hotplug I guess.
>=20
>=20

Some distros have :

$ cat /proc/sys/kernel/hotplug
/sbin/hotplug

http://linux.die.net/man/8/hotplug

Basically this starts a lot of process when a new device is created.

modprobe dummy numdummies=3D5000

This previous line ask 5000 asynchronous hotplug start, so it launches
thousands of processes, all fighting to get RTNL because they access
network configuration data.


Please note I was not commenting your patch (it seems fine at a first
glance), only warning people not doing "modprobe dummy numdummies=3D500=
0"
without thinking a bit if their machine wont crash or freeze :)



