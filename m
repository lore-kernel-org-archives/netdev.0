From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link // Kernel issue
Date: Thu, 26 Mar 2015 20:34:05 +0100
Message-ID: <201503262034.05499.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <201503230157.46489.wrosner@tirnet.de> <1427077997.25985.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:61557 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751864AbbCZTeK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 15:34:10 -0400
In-Reply-To: <1427077997.25985.59.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Eric

Am Montag, 23. M=C3=A4rz 2015 03:33:17 schrieben Sie:
> On Mon, 2015-03-23 at 01:57 +0100, Wolfgang Rosner wrote:
> > Are you ready to assist me on this track?
>
> First check if the problem is already solved, using this git tree ?
>
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git


Does not look like that :-(



I tried both 3.19.2 frome kernel.org and=20
a git clone frome above adress from "master" this morning.
$ uname -a
Linux cruncher 4.0.0-rc5+ #1 SMP Thu Mar 26 08:48:08 CET 2015 x86_64 GN=
U/Linux


Sorry when it took some time.

I've built a workaround for my aufs nfsroot to get rid of that, at leas=
t for=20
testing.
Both kernels were built w/o aufs patches, so we cannot blame this anymo=
re
(I've learned that people like to do so...)


-----------

I tried sequential run to check for jitter and to allow for adaptation

for i in `seq 10` ; do  iperf -c 192.168.130.225 -t 100 ; done

3.17 / 3.30 / 3.16 / 3.19 / 3.29 / 3.29 / 3.35 / 3.32 / 3.22 / 3.32
Gbits/sec

=2E..full bandwith at shared Link utilisation:

[  4]  0.0-10.0 sec  3.31 GBytes  2.84 Gbits/sec
[  3]  0.0-10.0 sec  3.32 GBytes  2.85 Gbits/sec
[SUM]  0.0-10.0 sec  6.63 GBytes  5.69 Gbits/sec

=2E..full bandwith (5.66 Gbits/sec) in the opposite direction

(Test figures are from davem 4.0.0-rc5+, on 3.19.2 they were quite the =
same)

------------------------

Tried a look at differences in kernel .config
between the versions where the problem occured

diff /boot/config-3.16.0-0.bpo.4-amd64 /boot/config-3.19.0 | less

there is one occurence of TCP
'> # CONFIG_TCP_CONG_DCTCP is not set

but it should not hurt if it is not set, should it?

All the other stuff does not ring any bell wiht my (very limited) range=
 of=20
experience.


So what next?



Wolfgang Rosner
