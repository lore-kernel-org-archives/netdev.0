From: Joao Correia <joaomiguelcorreia@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Tue, 7 Jul 2009 11:40:16 +0100
Message-ID: <a5d9929e0907070340y63280508t92e6c7e4ce464994@mail.gmail.com>
References: <200907031326.21822.andres@anarazel.de> <20090706163106.GA4559@ami.dom.local>
	<a5d9929e0907061023g4306d80ewfc8907653b949005@mail.gmail.com>
	<200907061926.43625.andres@anarazel.de> <20090707065014.GA3296@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andres Freund <andres@anarazel.de>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:51991 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbZGGKke convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 06:40:34 -0400
In-Reply-To: <20090707065014.GA3296@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am now running 2.6.31-rc2 for a couple of hours, no freeze.

Let me know what/if i can help with tracking down the original source
of the problem.

Thank you very much for your time,
Joao Correia

On Tue, Jul 7, 2009 at 7:50 AM, Jarek Poplawski<jarkao2@gmail.com> wrot=
e:
> On Mon, Jul 06, 2009 at 07:26:43PM +0200, Andres Freund wrote:
>> On Monday 06 July 2009 19:23:18 Joao Correia wrote:
>> > Hello
>> >
>> > Since i already had the kernel compiled and ready to boot when i r=
ead
>> > this, i gave it a go anyway :-).
>> >
>> > I can reproduce the freeze with those 4 patches applied, so i can
>> > confirm that its, at least, related to, or exposed by, those patch=
es.
>> > There must be something else too, or its just too much fuzziness, =
but
>> > the freeze takes a bit more time (approximately five minutes, give=
 or
>> > take) compared to the instant freeze before, but its there with th=
e
>> > patches, and without them, no freeze.
>> >
>> > I assume there isnt a "safe" way to get them out of current .31-rc=
's,
>> > right?
>> `echo 0 > /proc/sys/kernel/timer_migration` should mitigate the prob=
lem.
>
> I guess it should fix it entirely. Btw., here is a patch disabling th=
e
> timers' part, so to make it hrtimers only. Could you try?
>
> Thanks,
> Jarek P.
> ---
>
> diff --git a/kernel/timer.c b/kernel/timer.c
> index 0b36b9e..011429c 100644
> --- a/kernel/timer.c
> +++ b/kernel/timer.c
> @@ -634,7 +634,7 @@ __mod_timer(struct timer_list *timer, unsigned lo=
ng expires,
>
> =A0 =A0 =A0 =A0cpu =3D smp_processor_id();
>
> -#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
> +#if 0
> =A0 =A0 =A0 =A0if (!pinned && get_sysctl_timer_migration() && idle_cp=
u(cpu)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int preferred_cpu =3D get_nohz_load_ba=
lancer();
>
>
