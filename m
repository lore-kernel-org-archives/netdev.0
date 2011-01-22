From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems with /proc/net/tcp6  - possible bug - ipv6
Date: Sat, 22 Jan 2011 09:59:41 +0100
Message-ID: <1295686781.2609.37.camel@edumazet-laptop>
References: <702550.61465.qm@web63902.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: PK <runningdoglackey@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <702550.61465.qm@web63902.mail.re1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 21 janvier 2011 =C3=A0 22:30 -0800, PK a =C3=A9crit :
> Creating many ipv6 connections hits a ceiling on connections/fds ; ok=
ay, fine.
>=20
> But in my case I'm seeing millions of entries spring up within a few =
seconds and=20
> then vanish within a few minutes, in /proc/net/tcp6 (vanish due to ga=
rbage=20
> collection?)
>=20
> Furthermore I can trigger this easily on vanilla kernels from 2.6.36 =
to=20
> 2.6.38-rc1-next-20110121  inside a ubuntu 10.10 amd64 vm, causing the=
 kernel to=20
> spew warnings.  There is also some corruption in the logs (see kernel=
-sample.log=20
> line 296), but that may be unrelated.
>=20
> More explanation, kernel config of the primary machine I saw this on,=
 sample=20
> ruby script to reproduce (inside the ubuntu VMs I apt-get and use rub=
y-1.9.1),=20
> are located at
> https://github.com/runningdogx/net6-bug
>=20
> Seems to only affect 64-bit.  So far I have not been able to reproduc=
e on 32-bit=20
> ubuntu VMs of any kernel version.
> Seems to only affect IPv6.  So far I have not been able to reproduce =
using IPv4=20
> connections (and watching /proc/net/tcp of course).
> Does not trigger the bug if the connections are made to ::1.  Only ex=
ternally=20
> routable local and global IPv6 addresses seem to cause problems.
> Seems to have been introduced between 2.6.35 and 2.6.36 (see README o=
n github=20
> for more kernels I've tried)
>=20
> All the tested Ubuntu VMs are stock 10.10 userland, with vanilla kern=
els (the=20
> latest ubuntu kernel is 2.6.35-something, and my initial test didn't =
show it=20
> suffering from this problem)
>=20
> Originally noticed on separate Gentoo 64-bit non-vm system when doing=
 web=20
> benchmarking.
>=20
> not subscribed, so please keep me in cc although I'll try to follow t=
he thread
>=20
>=20

Hi PK (Sorry, your real name is hidden)

I could not reproduce this on current linux-2.6 kernel.

How many vcpus running in your VM, and memory ?

Note : a recent commit did fix /proc/net/tcp[6] behavior

commit 1bde5ac49398a064c753bb490535cfad89e99a5f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Dec 23 09:32:46 2010 -0800

    tcp: fix listening_get_next()
   =20
    Alexey Vlasov found /proc/net/tcp could sometime loop and display
    millions of sockets in LISTEN state.
   =20
    In 2.6.29, when we converted TCP hash tables to RCU, we left two
    sk_next() calls in listening_get_next().
   =20
    We must instead use sk_nulls_next() to properly detect an end of ch=
ain.
   =20
    Reported-by: Alexey Vlasov <renton@renton.name>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
