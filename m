From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 13/17] net: gianfar: remove misuse of IRQF_NO_SUSPEND
 flag
Date: Thu, 24 Sep 2015 00:03:55 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509232339090.4001@nanos>
References: <1442850433-5903-1-git-send-email-sudeep.holla@arm.com> <1442850433-5903-14-git-send-email-sudeep.holla@arm.com> <BY2PR0301MB072700F43F00CFC273FED1B59C460@BY2PR0301MB0727.namprd03.prod.outlook.com> <alpine.DEB.2.11.1509211848510.5606@nanos>
 <CADRPPNS_8PBHmm7jpindmg9pA5yEerM96JdpBtBz5BqOBFdUkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Manoil Claudiu <claudiu.manoil@freescale.com>,
	Sudeep Holla <sudeep.holla@arm.com>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hao <haokexin@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:47249 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbbIWWEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:04:38 -0400
In-Reply-To: <CADRPPNS_8PBHmm7jpindmg9pA5yEerM96JdpBtBz5BqOBFdUkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015, Li Yang wrote:
> On Mon, Sep 21, 2015 at 11:51 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Mon, 21 Sep 2015, Manoil Claudiu wrote:
> >> >The device is set as wakeup capable using proper wakeup API but the
> >> >driver misuses IRQF_NO_SUSPEND to set the interrupt as wakeup source
> >> >which is incorrect.
> >> >
> >> >This patch removes the use of IRQF_NO_SUSPEND flags replacing it with
> >> >enable_irq_wake instead.
> >> >
> >>
> >> What would be the purpose of IRQF_NO_SUSPEND flag then?  The flag is a
> >> friendlier API compared to calling enable_irq_wake().  For older kernels,
> >
> > It's not an API, it's just a bandaid for lazy programmers.
> >
> >> on PPC architectures, the flag did the job.  When did this change? Since
> >> when using IRQF_NO_SUSPEND is a "misuse"?
> >
> > It always was. Simply because IRQF_NO_SUSPEND has absolutely nothing
> > to do with wakeup interrupt sources. It's a flag which excludes the
> > interrupt from the suspend mechanism, but it does not flag it a wakeup
> > source.
> 
> It was not very clear on the intended use of IRQF_NO_SUSPEND at the
> beginning as it was not documented anywhere.  It's good that we have
> the Documentation/power/suspend-and-interrupts.txt to clarify that
> now.

This is complete and utter bullshit to put it blunt.

The documentation of IRQF_NO_SUSPEND as non suitable for marking a
particular device interrupt as wakeup source was added on Feb 20 2015
with commit 737eb0301f2. Further clarification was added with commit
7438b633a6b on Mar 4 2015.

The IRQF_NO_SUSPEND crap was introduced to gianfar with commit
614b42426cc3 on Jul 31 2015.

Did you really expect that nobody will notice that the documentation
which you praise now, has been available FIVE month before you decided
to ignore it?

You can play your $corp fingerpointing games inside of your $corp
without someone noticing, but in that community this is an absolute
nono.

No thanks,

   tglx
