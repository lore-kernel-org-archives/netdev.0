From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Thu, 15 Oct 2015 10:15:57 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510151014330.3960@nanos>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com> <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com> <alpine.DEB.2.11.1510132116480.25029@nanos> <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Oct 2015, Christopher Hall wrote:
> On Tue, 13 Oct 2015 12:42:52 -0700, Thomas Gleixner <tglx@linutronix.de>
> wrote:
> > On Mon, 12 Oct 2015, Christopher S. Hall wrote:
> > > audio.
> > 
> > This wants to be a seperate patch, really.
> 
> OK. This makes sense, I'll do this the next time.
> 
> > > +/* This needs to be 3 or greater for backtracking to be useful */
> > 
> > Why?
> 
> The current index points to a copy and the next may be being changed by
> update_wall_time(). Leaving n-2 entries available with useful history in them.
> I'll add more descriptive comments here.
> 
> > 
> > > +#define SHADOW_HISTORY_DEPTH 7
> > 
> > And that number is 7 because?
> 
> Due to power of 2 it will be 8 instead. As above the useful history is 8-2*1
> ms (1 ms is the minimum jiffy length).  Array size 4 would not be enough
> history for the DSP which requires 4 ms of history, in the worst case.

And how exactly becomes 7 magically 8?
 
> > 
> > What's the point of this? Why are you not making the few lines which
> > you can actually reuse a helper function and leave the PTP code alone?
> 
> The audio driver is structured in such a way that it's simpler to provide a
> value rather than a callback.  I changed this to allow the audio developers to
> provide an ART value as input.  If a callback is provided, the resulting
> counter value is guaranteed to be later than cycle_last and there is no need
> to do extra checking (the goto skips that check).  Is this an answer to your
> question?

Make it a seperate function which can hand in the information and
leave the PTP specific sample/conversion function alone.

Thanks,

	tglx
