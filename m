From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link // Kernel issue
Date: Fri, 27 Mar 2015 19:46:07 +0100
Message-ID: <201503271946.07464.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <1427077997.25985.59.camel@edumazet-glaptop2.roam.corp.google.com> <201503262034.05499.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:3623 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbbC0SqJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 14:46:09 -0400
In-Reply-To: <201503262034.05499.wrosner@tirnet.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,


I tried to discern the possibilities of Debian patches having solved th=
e=20
problem vs, regression bug in recent Kernels.

So I tested:
- Vanilla 3.16.7
- recent Debian 3.19.1

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

results:

- Vanilla 3.16.7
from
https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.16.7.tar.xz
result: really bad,=20
~ 500 Mbit /s both inbound and outwards
inbound even with -P24 parallel threads not more than 800 Mbit
outobund with -P12 we are back over 5 Gbit/s again

=46rom that, to mee it looks like the problem was introduced before  3.=
16.7
but only partly solved since then.

I tried to map vailla versions with the davem fork,
http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/tree/
 but got lost in git / developer workflow .



- recent Debian 3.19.1
same results as with any other recent kernel
	inbound > 5.5 GBit
	outbound ~ 3.2 GBit
	outbound -P 2 > 5 Gbit


So it looks like the debian people have _not_ found the solution, but w=
ere=20
just lucky enough with their=20
 3.16.0-0.bpo.4-amd64 #1 SMP Debian 3.16.7-ckt4-3~bpo70+1=20

not to hit it yet...



Am Donnerstag, 26. M=C3=A4rz 2015 20:34:05 schrieb Wolfgang Rosner:
> Hello, Eric
>
> Am Montag, 23. M=C3=A4rz 2015 03:33:17 schrieben Sie:
> > On Mon, 2015-03-23 at 01:57 +0100, Wolfgang Rosner wrote:
> > > Are you ready to assist me on this track?
> >
> > First check if the problem is already solved, using this git tree ?
> >
> > http://git.kernel.org/cgit/linux/kernel/git/davem/net.git
>
> Does not look like that :-(
>
>
>
> I tried both 3.19.2 frome kernel.org and
> a git clone frome above adress from "master" this morning.
> $ uname -a
> Linux cruncher 4.0.0-rc5+ #1 SMP Thu Mar 26 08:48:08 CET 2015 x86_64
> GNU/Linux
>
>
> Sorry when it took some time.
>
> I've built a workaround for my aufs nfsroot to get rid of that, at le=
ast
> for testing.
> Both kernels were built w/o aufs patches, so we cannot blame this any=
more
> (I've learned that people like to do so...)
>
>
> -----------
>
> I tried sequential run to check for jitter and to allow for adaptatio=
n
>
> for i in `seq 10` ; do  iperf -c 192.168.130.225 -t 100 ; done
>
> 3.17 / 3.30 / 3.16 / 3.19 / 3.29 / 3.29 / 3.35 / 3.32 / 3.22 / 3.32
> Gbits/sec
>
> ...full bandwith at shared Link utilisation:
>
> [  4]  0.0-10.0 sec  3.31 GBytes  2.84 Gbits/sec
> [  3]  0.0-10.0 sec  3.32 GBytes  2.85 Gbits/sec
> [SUM]  0.0-10.0 sec  6.63 GBytes  5.69 Gbits/sec
>
> ...full bandwith (5.66 Gbits/sec) in the opposite direction
>
> (Test figures are from davem 4.0.0-rc5+, on 3.19.2 they were quite th=
e
> same)
>
> ------------------------
>
> Tried a look at differences in kernel .config
> between the versions where the problem occured
>
> diff /boot/config-3.16.0-0.bpo.4-amd64 /boot/config-3.19.0 | less
>
> there is one occurence of TCP
> '> # CONFIG_TCP_CONG_DCTCP is not set
>
> but it should not hurt if it is not set, should it?
>
> All the other stuff does not ring any bell wiht my (very limited) ran=
ge of
> experience.
>
>
> So what next?
>
>
>
> Wolfgang Rosner
>
> --


Wolfgang Rosner
