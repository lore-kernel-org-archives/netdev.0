From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Wed, 8 Jul 2009 23:27:30 +0100
Message-ID: <a5d9929e0907081527n38a4c369k5b886520b7cc0229@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <200907071811.27570.andres@anarazel.de>
	<20090708080852.GC3148@ami.dom.local> <200907081029.34527.andres@anarazel.de>
	<20090708091344.GD3148@ami.dom.local> <a5d9929e0907081444r4a1e0828taf538c686577f09c@mail.gmail.com>
	<20090708220749.GA3666@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Freund <andres@anarazel.de>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:59458 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbZGHW1w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:27:52 -0400
In-Reply-To: <20090708220749.GA3666@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2009 at 11:07 PM, Jarek Poplawski<jarkao2@gmail.com> wro=
te:
> On Wed, Jul 08, 2009 at 10:44:47PM +0100, Joao Correia wrote:
>> Hello again
> Hello!
>
> ...
>> So again, the only thing that stops that freeze is =A0`echo 0 >>
>> /proc/sys/kernel/timer_migration`. Apologies for pointing you in the
>> wrong direction.
>
> No problem: the direction is almost right, we only need one U-turn ;-=
)
> In case you're not bored or too bored, one little patch to check the
> other side (after reverting the previous patch).
>
> Thanks,
> Jarek P.
> ---
>
> =A0kernel/hrtimer.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> index 9002958..23387e4 100644
> --- a/kernel/hrtimer.c
> +++ b/kernel/hrtimer.c
> @@ -203,7 +203,7 @@ switch_hrtimer_base(struct hrtimer *timer, struct=
 hrtimer_clock_base *base,
> =A0 =A0 =A0 =A0int cpu, preferred_cpu =3D -1;
>
> =A0 =A0 =A0 =A0cpu =3D smp_processor_id();
> -#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
> +#if 0
> =A0 =A0 =A0 =A0if (!pinned && get_sysctl_timer_migration() && idle_cp=
u(cpu)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0preferred_cpu =3D get_nohz_load_balanc=
er();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (preferred_cpu >=3D 0)
>

(this time i triple-checked :-) )

So, with only this last patch applied, no freeze. No need to disable
anything through /proc.

Where should i put the BUG_ON?

Joao Correia
