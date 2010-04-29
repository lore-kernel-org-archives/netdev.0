From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OFT - reserving CPU's for networking
Date: Thu, 29 Apr 2010 22:02:19 +0200
Message-ID: <1272571339.2209.76.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
	 <1272293707.19143.51.camel@edumazet-laptop>
	 <20100429174056.GA8044@gargoyle.fritz.box>
	 <1272563772.2222.301.camel@edumazet-laptop>
	 <20100429111047.031eeff9@nehalam>
	 <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Andi Kleen <ak@gargoyle.fritz.box>, netdev@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57604 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803Ab0D3RZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:25:32 -0400
Received: by bwz19 with SMTP id 19so273309bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 10:25:30 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 21:19 +0200, Thomas Gleixner a =C3=A9crit=
 :

> Say thanks to Intel/AMD for providing us timers which stop in lower
> c-states.
>=20
> Not much we can do about the broadcast lock when several cores are
> going idle and we need to setup a global timer to work around the
> lapic timer stops in C2/C3 issue.
>=20
> Simply the C-state timer broadcasting does not scale. And it was neve=
r
> meant to scale. It's a workaround for laptops to have functional NOHZ=
=2E
>=20
> There are several ways to work around that on larger machines:
>=20
>  - Restrict c-states
>  - Disable NOHZ and highres timers
>  - idle=3Dpoll is definitely the worst of all possible solutions
>=20
> > I keep getting asked about taking some core's away from clock and s=
cheduler
> > to be reserved just for network processing. Seeing this kind of stu=
ff
> > makes me wonder if maybe that isn't a half bad idea.
>=20
> This comes up every few month and we pointed out several times what
> needs to be done to make this work w/o these weird hacks which put a
> core offline and then start some magic undebugable binary blob on it.
> We have not seen anyone working on this, but the "set cores aside and
> let them do X" idea seems to stick in peoples heads.
>=20
> Seriously, that's not a solution. It's going to be some hacked up
> nightmare which is completely unmaintainable.
>=20
> Aside of that I seriously doubt that you can do networking w/o time
> and timers.
>=20

Thanks a lot !

booting with processor.max_cstate=3D1 solves the problem

(I already had a CONFIG_NO_HZ=3Dno conf, but highres timer enabled)

Even with _carefuly_ chosen crazy configuration (receiving a packet on =
a
cpu, then transfert it to another cpu, with a full 16x16 matrix
involved), generating 700.000 IPI per second on the machine seems fine
now.



