From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Subject: Fwd: Problems with ipv4 part of Kernels post-2.6.16
Date: Mon, 4 Sep 2006 00:10:35 +0200
Message-ID: <5a4c581d0609031510x4ba77b2fva764e2487ddf34f0@mail.gmail.com>
References: <20060903201335.GA3703@ime.usp.br> <20060903183403.GB604@1wt.eu>
	 <5a4c581d0609031507w54a397c4g2876b47b2fbbd45c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:25868 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750699AbWICWKg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2006 18:10:36 -0400
Received: by wx-out-0506.google.com with SMTP id s14so1663379wxc
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2006 15:10:35 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <5a4c581d0609031507w54a397c4g2876b47b2fbbd45c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry - reply-all got a bounce, didn't check the bad netdev address...

---------- Forwarded message ----------
=46rom: Alessandro Suardi <alessandro.suardi@gmail.com>
Date: Sep 4, 2006 12:07 AM
Subject: Re: Problems with ipv4 part of Kernels post-2.6.16
To: Willy Tarreau <w@1wt.eu>
Cc: Rog=E9rio Brito <rbrito@ime.usp.br>, linux-kernel@vger.kernel.org,
linux-netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>, "David
S. Miller" <davem@davemloft.net>


On 9/3/06, Willy Tarreau <w@1wt.eu> wrote:
> Hi Rog=E9rio,
>
> On Sun, Sep 03, 2006 at 05:13:35PM -0300, Rog=E9rio Brito wrote:
> > Hi, John, David and others developers.
> >
> > I have been trying to keep up with the kernel releases (not only th=
e
> > -rc ones, but also some -mm's) and I noticed something quite strang=
e:
> > with some post 2.6.16 kernels (say, 2.6.17), I can't access (from w=
here
> > I am) the site www.everymac.com, while I can access other sites.
>
> I believe I read on LKML last month that there's a problem on this si=
te
> with window scaling. There's a patch floating around to allow per
> destination window clamping. I believe that you can workaround the
> problem by disabling TCP window scaling :
>
>    echo 0 >/proc/sys/net/ipv4/tcp_window_scaling
>
> Hoping this helps,
> Willy

The above does help while hitting certain websites from behind my
 corporate proxy (while others are okay); same websites can be
 accessed without any issue from my home ISP connection.

I logged an internal ticket for this, will check whether there's been
 any update as of recently; both happens with recent 2.6.18-rc and
 with FC5-latest kernel.

> > This has made me quite curious, because just booting back with a
> > 2.6.16.x kernel, I could access it, which, of course, led me to thi=
nk
> > this was a problem with the networking part of the kernel.
> >
> > Well, to cut a long story short, yesterday I decided to learn how t=
o use
> > git, grabbed Linus's tree and started a bisection session.
> >
> > After 12 recompilations, I found the following patch being the firs=
t
> > suspect (sorry for the line wrapping, but I copied this one from on=
e
> > console to another, since I don't know how to generate it again wit=
h
> > git):
> >
> > - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -=
 - -
> > rbrito@dumont:/usr/local/media/progs/linux/kernel/linux-git$ git bi=
sect
> > good
> > 7b4f4b5ebceab67ce440a61081a69f0265e17c2a is first bad commit
> > commit 7b4f4b5ebceab67ce440a61081a69f0265e17c2a
> > Author: John Heffner <jheffner@psc.edu>
> > Date:   Sat Mar 25 01:34:07 2006 -0800
> >
> >     [TCP]: Set default max buffers from memory pool size
> >
> >     This patch sets the maximum TCP buffer sizes (available to auto=
matic
> >     buffer tuning, not to setsockopt) based on the TCP memory pool =
size.
> >     The maximum sndbuf and rcvbuf each will be up to 4 MB, but no m=
ore
> >     than 1/128 of the memory pressure threshold.
> >
> >     Signed-off-by: John Heffner <jheffner@psc.edu>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > :040000 040000 514849b6a38c5fb671f3aeae1c0108a0e8e897dc
> > 3b912fd10db444b22262f995fac99f2851363531 M      net
> > rbrito@dumont:/usr/local/media/progs/linux/kernel/linux-git$
> > - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -=
 - -
> >
> > I'm currently connected to my provider via cable modem and I'm assi=
gned
> > an IP address via DHCP (actually, I'm using a D-Link DI-524 router =
in
> > between, but I already tested *without* the router in the middle an=
d the
> > problem remains). The contents of my /etc/sysctl.conf file are atta=
ched.
> >
> > My userspace is Debian's testing/etch, regularly upgraded every day=
=2E My
> > system is a Duron 1.1GHz, with 512MB of RAM and a KT133 (VIA) chips=
et,
> > with the network card being a Realtek RTL8139.
> >
> > I would like to point out that this has prevented me from using/tes=
ting
> > other newer kernels. :-(
> >
> > If anything else is required, please, don't hesitate to ask. I will=
 try
> > my best to use any patches that may seem relevant, until we can poi=
nt
> > out what may be happening.
> >
> >
> > Thanks, Rog=E9rio Brito.
> >
> > P.S.: Please, I'm not (currently) subscribed to any mailing list.  =
I'd
> > appreciate if the CCs weren't trimmed.
> > --
> > Rog=E9rio Brito : rbrito@ime.usp.br : http://www.ime.usp.br/~rbrito
> > Homepage of the algorithms package : http://algorithms.berlios.de
> > Homepage on freshmeat:  http://freshmeat.net/projects/algorithms/
>
> > #
> > # /etc/sysctl.conf - Configuration file for setting system variable=
s
> > # See sysctl.conf (5) for information.
> > #
> >
> > # Uncomment the following to stop low-level messages on console
> > #kernel.printk =3D 4 4 1 7
> >
> > ##############################################################3
> > # Functions previously found in netbase
> > #
> > #net.ipv4.conf.default.forwarding=3D1
> > #net.ipv6.conf.default.forwarding=3D1
> >
> > dev.rtc.max-user-freq=3D1024
> > net.ipv4.conf.all.accept_redirects=3D0
> > net.ipv4.conf.all.accept_source_route=3D0
> > net.ipv4.conf.all.log_martians=3D1
> > net.ipv4.conf.all.rp_filter=3D1
> > net.ipv4.conf.default.accept_redirects=3D0
> > net.ipv4.conf.default.accept_source_route=3D0
> > net.ipv4.conf.default.log_martians=3D1
> > net.ipv4.conf.default.rp_filter=3D1
> > net.ipv4.icmp_echo_ignore_broadcasts=3D1
> > net.ipv4.tcp_syncookies=3D1

--alessandro

"What's the name of the word for the precise moment when you
 realize that you've actually forgotten how it felt to make love
 to somebody you really liked a long time ago?"
"There isn't one."
"Oh. I thought maybe there was."
     (The Sandman, dialogue between Delirium and Dream)


--=20
--alessandro

"What's the name of the word for the precise moment when you
 realize that you've actually forgotten how it felt to make love
 to somebody you really liked a long time ago?"
"There isn't one."
"Oh. I thought maybe there was."
     (The Sandman, dialogue between Delirium and Dream)

--=20
VGER BF report: H 3.88436e-05
