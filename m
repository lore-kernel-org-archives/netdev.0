From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v6 3/9] Add correlated clocksource relating aliased
 auxiliary and system clocks
Date: Fri, 15 Jan 2016 11:29:19 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601151108110.3575@nanos>
References: <1452687149-11281-1-git-send-email-christopher.s.hall@intel.com> <1452687149-11281-4-git-send-email-christopher.s.hall@intel.com> <CALAqxLXZhpGUv2UAPLmSboW=nhyW+eXvrMaUkZCy7JQh=WgkLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLXZhpGUv2UAPLmSboW=nhyW+eXvrMaUkZCy7JQh=WgkLQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Jan 2016, John Stultz wrote:
> On Wed, Jan 13, 2016 at 4:12 AM, Christopher S. Hall
> <christopher.s.hall@intel.com> wrote:
> > +/*
> > + * struct correlated_cs - Descriptor for a clocksource correlated to another
> > + *     clocksource
> > + * @related_cs:                Pointer to the related timekeeping clocksource
> > + * @convert:           Conversion function to convert a timestamp from
> > + *                     the correlated clocksource to cycles of the related
> > + *                     timekeeping clocksource
> > + */
> > +struct correlated_cs {
> > +       struct clocksource      *related_cs;
> > +       cycle_t                 (*convert)(struct correlated_cs *cs,
> > +                                          cycle_t cycles);
> > +};
> > +
> 
> So.. In reworking your patch set, I've preserved this, but I'm still
> not totally convinced. Its a generic structure, but not used by any
> generic code and its only used by hardware specific implementations
> (ie: the tsc and e1000e_hwts logic). It seems like this could be a
> tsc.h specific structure w/o a real issue.

That correlated_cs is my fault. I invented that when I had that first stab on
the cross time stamp thing.
 
> And really this doesn't seem to be a generic thing. The e1000e hwts is
> always the ART based. Its not likely these sorts of cross hardware
> timestamps are going to be completely abstract and interchangeable,
> is it?

They might be in future. I guess other archs will provide similar means to
distribute an always on timer to PCIe for timestamping purposes.

So the question is whether we should expose that timestamp reference via a
generic mechanism, e.g. store it somewhere in the pci root complex or wherever
the appropriate point for it is.

Though for now, we certainly can make that x86 private and deal with it when
others come along.

Thanks,

	tglx
