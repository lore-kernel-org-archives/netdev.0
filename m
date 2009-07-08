From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Thu, 9 Jul 2009 00:42:59 +0200
Message-ID: <20090708224259.GC3666@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de> <20090708080852.GC3148@ami.dom.local> <200907081029.34527.andres@anarazel.de> <20090708091344.GD3148@ami.dom.local> <a5d9929e0907081444r4a1e0828taf538c686577f09c@mail.gmail.com> <20090708220749.GA3666@ami.dom.local> <a5d9929e0907081527n38a4c369k5b886520b7cc0229@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:50807 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbZGHWnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:43:32 -0400
Content-Disposition: inline
In-Reply-To: <a5d9929e0907081527n38a4c369k5b886520b7cc0229@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2009 at 11:27:30PM +0100, Joao Correia wrote:
> On Wed, Jul 8, 2009 at 11:07 PM, Jarek Poplawski<jarkao2@gmail.com> w=
rote:
> > On Wed, Jul 08, 2009 at 10:44:47PM +0100, Joao Correia wrote:
> >> Hello again
> > Hello!
> >
> > ...
> >> So again, the only thing that stops that freeze is =A0`echo 0 >>
> >> /proc/sys/kernel/timer_migration`. Apologies for pointing you in t=
he
> >> wrong direction.
> >
> > No problem: the direction is almost right, we only need one U-turn =
;-)
> > In case you're not bored or too bored, one little patch to check th=
e
> > other side (after reverting the previous patch).
> >
> > Thanks,
> > Jarek P.
> > ---
> >
> > =A0kernel/hrtimer.c | =A0 =A02 +-
> > =A01 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> > index 9002958..23387e4 100644
> > --- a/kernel/hrtimer.c
> > +++ b/kernel/hrtimer.c
> > @@ -203,7 +203,7 @@ switch_hrtimer_base(struct hrtimer *timer, stru=
ct hrtimer_clock_base *base,
> > =A0 =A0 =A0 =A0int cpu, preferred_cpu =3D -1;
> >
> > =A0 =A0 =A0 =A0cpu =3D smp_processor_id();
> > -#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
> > +#if 0
> > =A0 =A0 =A0 =A0if (!pinned && get_sysctl_timer_migration() && idle_=
cpu(cpu)) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0preferred_cpu =3D get_nohz_load_bala=
ncer();
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (preferred_cpu >=3D 0)
> >
>=20
> (this time i triple-checked :-) )
>=20
> So, with only this last patch applied, no freeze. No need to disable
> anything through /proc.
>=20
> Where should i put the BUG_ON?

Hmm... Not so fast! I've looked in timers till now; "tomorrow" I'll
"change resolution". ;-)

Thanks again,
Jarek P.
