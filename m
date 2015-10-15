From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Thu, 15 Oct 2015 07:57:35 +0200
Message-ID: <20151015055734.GB4784@netboy>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1510132116480.25029@nanos>
 <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>, jeffrey.t.kirsher@intel.com,
	hpa@zytor.com, mingo@redhat.com, john.stultz@linaro.org,
	peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 14, 2015 at 06:57:33PM -0700, Christopher Hall wrote:
> >>+#define SHADOW_HISTORY_DEPTH 7
> >
> >And that number is 7 because?
> 
> Due to power of 2 it will be 8 instead. As above the useful history is 8-2*1
> ms (1 ms is the minimum jiffy length).  Array size 4 would not be enough
> history for the DSP which requires 4 ms of history, in the worst case.

Just as I suspected, the magic number 7 is based on the needs of one
particular user.  What about the next user who comes along needing 10
milliseconds?  That will not do.  Any new interface should be generic
enough to support a wide range of users.

So I think this approach is all wrong.  Here is an idea for you to
consider.  Instead of mucking with the TK, let the user code (possibly
in-kernel) sample ART/sys pairs and interpolate the ART/dev time
stamps.  That way, the user can choose the range and resolution that
he needs.

> The audio driver is structured in such a way that it's simpler to provide a
> value rather than a callback.

Can you please provide a link to the audio driver that uses this new
interface?

Thanks,
Richard
