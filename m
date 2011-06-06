From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 22:32:32 +0200
Message-ID: <1307392352.2642.16.camel@edumazet-laptop>
References: <1307389540.2642.3.camel@edumazet-laptop>
	 <201106062206.29134.arnd@arndb.de>
	 <1307391174.2642.8.camel@edumazet-laptop>
	 <201106062226.02635.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36197 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756071Ab1FFUck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:32:40 -0400
Received: by wwk4 with SMTP id 4so1858183wwk.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 13:32:39 -0700 (PDT)
In-Reply-To: <201106062226.02635.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 22:26 +0200, Arnd Bergmann a =C3=A9crit :
> On Monday 06 June 2011 22:12:54 Eric Dumazet wrote:
> > So for an old binary, compiled at the time SIOCBRADDBR wasnt there =
(in
> > include file I mean), we ended doing :
> >=20
> >         {
> >                 char _br[IFNAMSIZ];
> >                 unsigned long arg[3]
> >                         =3D { BRCTL_ADD_BRIDGE, (unsigned long) _br=
 };
> >=20
> >                 strncpy(_br, brname, IFNAMSIZ);
> >                 ret =3D ioctl(br_socket_fd, SIOCSIFBR, arg);
> >         }
> >=20
> > And this breaks on 64bit kernel
>=20
> Ah, you were quicker than me at posting this ;-)
>=20
> > I guess we shall add some logic in kernel to support SIOCSIFBR
> > afterall ;)
> >=20
> > Thanks !
> >=20
> > BTW: I confirm that compiling an up2date 32bit brctl with an up2dat=
e
> > include files is OK on 64bit kernel.
>=20
> I did a little more digging in the history and found that the code in
> brctl was added in this commit:
>=20
> commit 328f4711bbc369dcccf8f8cfba2adf5dd0f74479
> Author: shemminger <shemminger>
> Date:   Fri May 21 17:41:48 2004 +0000
>=20
>     New version of command and library that use sysfs.
>     Update make system to build with or without sysfs.
>=20
> It's not completely clear to me if it's worth supporting older
> user space than this, but it's certainly possible.
>=20
> 	Arnd

In my case, I used latest bridge-utils tree, but compiled on a RHEL4
machine :)

# ls -l /usr/include/linux/sockios.h
-rw-r--r--  1 root root 5369 Mar 18  2002 /usr/include/linux/sockios.h
# rpm -qf /usr/include/linux/sockios.h
glibc-kernheaders-2.4-9.1.100.EL

Please note that pretty everything works on this 32bit distro machine,
but a 64bit kernel.



