From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Fri, 4 Sep 2015 14:50:47 -0700
Message-ID: <CALAqxLViXLWyhEF_etEeyPxZG3M=69pZ7fD8X8FKoM5QNKQ5WQ@mail.gmail.com>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
	<1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
	<alpine.DEB.2.11.1508222143530.3873@nanos>
	<B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"peterz@infradead.org" <peterz@infradead.org>
To: "Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2015 at 4:20 PM, Hall, Christopher S
<christopher.s.hall@intel.com> wrote:
> For example, supply the ART value as an argument and, in the case of the realtime
> clock, keep a short history of clock changes.  It would fail in cases where there
> are a lot of calls to adjtimex(), but it will would work most of the time.

So, I really don't think something like this would be reasonable. For
one, keeping track of the adjtimex adjustments would be difficult
enough to do sanely, but the real issue is that the clock has its own
long-term error correction adjustments that it does in order to keep
long term frequency accuracy with coarsely adjusted clocksources.
Trying to track those small oscillation intervals would be even more
complicated.

I still think that being able to calculate the CLOCK_MONOTONIC_RAW
value for a given ART counter value is reasonable, and then one can
use the getnstime_raw_and_real() to get a current raw/real sync point,
which you can then calculate the raw delta, and subtract that from the
sycned real timestamp.

You're error there would be bound by the maxium clocksource adjustment
rate * the raw-delta interval length.

To clarify on the need to understand if this error would be
reasonable, can you provide a sense of what the delay from an ART read
to trying to calculate a REALTIME value might be?

thanks
-john
