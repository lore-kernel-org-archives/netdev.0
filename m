From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback and Nagle's algorithm
Date: Tue, 12 Apr 2011 15:08:23 +0200
Message-ID: <1302613703.3233.40.camel@edumazet-laptop>
References: <1302575869.13492.1440076201@webmail.messagingengine.com>
	 <BANLkTi=jpdLRc35DkBhLmUr8-P+ggcrgoA@mail.gmail.com>
	 <1302606246.21782.1440195277@webmail.messagingengine.com>
	 <alpine.LRH.2.00.1104121354010.6953@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adam McLaurin <lkml@irotas.net>,
	Will Newton <will.newton@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1104121354010.6953@twin.jikos.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 12 avril 2011 =C3=A0 13:54 +0200, Jiri Kosina a =C3=A9crit :
> On Tue, 12 Apr 2011, Adam McLaurin wrote:
>=20
> > > It may be caused by an increase in context switch rate, as both s=
ender
> > > and receiver are on the same machine.
> >=20
> > I'm not sure that's what's happening, since the box where I'm runni=
ng
> > this test has 8 physical CPU's and 32 cores in total.
>=20
> Have you tried firing up the testcase under perf, to see what it reve=
als=20
> as the bottleneck?
>=20
CC netdev

This rings a bell here.

I suspect we hit mod_timer() / lock_timer_base()  because of delack
timer constantly changing.

I remember raising this point last year :

http://kerneltrap.org/mailarchive/linux-netdev/2010/5/20/6277741

David answer :=20
http://kerneltrap.org/mailarchive/linux-netdev/2010/6/2/6278430

I am afraid no change was done...
