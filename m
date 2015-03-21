From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces
 with "ktime_t" type
Date: Sat, 21 Mar 2015 08:24:09 +0100
Message-ID: <20150321072407.GA4701@netboy>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
 <201503201443.42672.arnd@linaro.org>
 <20150320164951.GA25334@localhost.localdomain>
 <201503210216.41497.arnd@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baolin Wang <baolin.wang@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.com>,
	tglx@linutronix.de
To: Arnd Bergmann <arnd@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201503210216.41497.arnd@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 21, 2015 at 02:16:41AM +0100, Arnd Bergmann wrote:
> This was the first idea, but it seems a bit silly when all the drivers
> use a 64-bit nanosecond value just like ktime_t.

Not true of all drivers.  In fact, the most capable devices (phyter
and i210) have a split representation.

> While both of the
> current users require a timespec at the moment, it's possible that
> there would one day be a third user that actually can make sense of
> a ktime_t, and then we'd avoid the expensive back-and-forth conversion.

Speculative, and has nothing to do with the 2038 issue.  Let us solve
that problem first.
 
> For now, using ktime_t in the interface merely simplifies the drivers
> by moving the conversion into the subsystem,

Right now we have 17 drivers, tested and debugged, that perform the
conversion for the particular hardware correctly.  Who is going to
test all of the "unconverted" code?  Baolin?

> but it is not any more
> or less efficient than the previous method.

Right, so no point in changing it.

> Of course, but it would be rather bad style.

Introducing useless code just to remove it again is also bad style.

I disagree with the approach presented here.  The problem at hand is
the 2038 issue.  Let's fix that first, in the easiest way, with the
least churn, namely by using timespec64 in place of timespec.  Once
that is done, we can change over to ktime_t, if and when the need
arises.

Thanks,
Richard
