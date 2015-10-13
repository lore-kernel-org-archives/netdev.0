From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 13 Oct 2015 09:51:02 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510130944520.6097@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com> <20151013045832.GA2437@netboy>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151013045832.GA2437@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Oct 2015, Richard Cochran wrote:
> On Mon, Oct 12, 2015 at 11:45:19AM -0700, Christopher S. Hall wrote:
> > The transforms such an application would
> > perform are:
> > 
> > System Clock <-> Audio clock
> > System Clock <-> Network Device Clock [<-> PTP Master Clock]
> 
> This is extra work with no benefit.  In fact, this hurts you
> because of the need to take avoid update_wall_time AND because of the
> NTP frequency adjustments.  Cascaded servos are prone to gain peaking,
> and this can easily avoided in this case.

In such a system the frequency updates are coming from PTP, so you
have a strong correlation.
  
> > Modern Intel platforms can perform a more accurate cross-
> > timestamp in hardware (ART,audio device clock).  The audio driver
> > requires ART->system time transforms -- the same as required for
> > the network driver.
> 
> No, it doesn't need the system time.  It only needs the PTP time.
> 
> > The modification to the original patch accomodates these
> > slow devices by adding the option of providing an ART value outside
> > of the retry loop and adding a history which can consulted in the
> > case of an out of date counter value. The history is kept by
> > making the shadow_timekeeper an array. Each write to the
> > timekeeper rotates through the array, preserving a
> > history of updates.
> 
> This is all wrong.  All you need to provide the DSP with (ART, PTP)
> pairs.  This can be done in a multiple of the DSP period, like every
> 1, 10, or 100 milliseconds.

You are restricting the problem space to this particular use
case. There are other use cases where PTP is not available or not the
relevant reference, but you still want to correlate time domains to
ART.

Thanks,

	tglx
