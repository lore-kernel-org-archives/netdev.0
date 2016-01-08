From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC v5 3/6] Add history to cross timestamp interface supporting
 slower devices
Date: Fri, 8 Jan 2016 15:04:28 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1601081503210.3575@nanos>
References: <1451911523-8534-1-git-send-email-christopher.s.hall@intel.com> <1451911523-8534-4-git-send-email-christopher.s.hall@intel.com> <CALAqxLVACLP1_PGWh5Ha9P6DT+HfDu9vg-B5NCShuFvNu21WUQ@mail.gmail.com>
 <op.yawaqe0i1774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <op.yawaqe0i1774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jan 2016, Christopher Hall wrote:
> On Wed, 06 Jan 2016 11:37:23 -0800, John Stultz <john.stultz@linaro.org>
> wrote:
> > I've not done a super close reading here. But is it very likely the
> > the history_ref->cs_seq is the same as the captured seq? I thought
> > this history_ref was to allow old cross stamps to be used to improve
> > the back-calculation of the time at the given cycle value. So throwing
> > them out if they are older then the last tick seems strange.
> 
> Maybe this needs more explanation. The clocksource sequence (cs_seq) is
> incremented for each change in clocksource. I use this to detect a rare corner
> case where the clocksource is changed from (on x86 anyway) TSC and then back.
> If the history crosses one of these changes then interpolation shouldn't be
> attempted (return error). It's not really enough when using the history to
> just check that the current clocksource is equal to the one used at the start
> of the history. The clocksource must not have changed at all. To answer your
> question, it's not at all likely that this would occur.

You can flush the history when a clocksource change happens. No need to add
extra data to the core structures.

Thanks,

	tglx
