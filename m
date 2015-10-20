From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Mon, 19 Oct 2015 17:36:56 -0700
Message-ID: <CALAqxLXu_C8sWaKyxqXJPFV+m5Zdk=4q4s7O6NoLR1B8bbyuxg@mail.gmail.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
	<1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
	<alpine.DEB.2.11.1510132116480.25029@nanos>
	<op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
	<alpine.DEB.2.11.1510151014330.3960@nanos>
	<op.x6r25dza1774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"x86@kernel.org" <x86@kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, kevin.b.stanton@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <op.x6r25dza1774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 19, 2015 at 5:18 PM, Christopher Hall
<christopher.s.hall@intel.com> wrote:
> On Thu, 15 Oct 2015 01:15:57 -0700, Thomas Gleixner <tglx@linutronix.de>
> wrote:
>>>
>>> >
>>> > > +#define SHADOW_HISTORY_DEPTH 7
>>> >
>>> > And that number is 7 because?
>>>
>>> Due to power of 2 it will be 8 instead. As above the useful history is
>>> 8-2*1
>>> ms (1 ms is the minimum jiffy length).  Array size 4 would not be enough
>>> history for the DSP which requires 4 ms of history, in the worst case.
>>
>>
>> And how exactly becomes 7 magically 8?
>
>
> I'm making the array size a power of two, per your suggestion.
>
> In my view, the candidate array sizes are 4 and 8.  But the DSP driver code
> requires that it be at least 8.  Here is my reasoning:
>
> The number of shadow_timekeeper array elements that contain useful history
> is n-2 where n is the size of the shadow_timekeeper array.  This is true
> because shadow_timekeeper[shadow_index] is a copy of tk_core.timekeeper
> (this isn't history).  The next entry of the shadow_timekeeper array may be
> in-flight and contain invalid information, because update_wall_time() makes
> changes to the next entry of shadow timekeeper outside of the sequence lock.
> If that occurs, get_correlated_timestamp() would not be notified of this
> change through a change in sequence number.

Sorry for not commenting here earlier. But I've sort of loosely been
following this thread.

I'm still very very concerned about the complexity of adding any sort
of array of timekeeper structures for historical purposes, and like
Richard, I feel like the rational for all of this has not been made
very clear.

Thomas seems to be a helpful advocate, but I suspect the use case has
been explained to him in detail off list.

If we're only tracking 4ms of history, how does this solution
measurably improve the error over using the timestamps to generate
MONOTONIC_RAW clock deltas (which doesn't require keeping any history)
and using getnstime_raw_and_real to take an anchor point to calculate
the delta from?  Why is adding complexity necessary?

thanks
-john
