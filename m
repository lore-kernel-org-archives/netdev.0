From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces with "ktime_t" type
Date: Sat, 21 Mar 2015 02:16:41 +0100
Message-ID: <201503210216.41497.arnd@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org> <201503201443.42672.arnd@linaro.org> <20150320164951.GA25334@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Baolin Wang <baolin.wang@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.com>,
	tglx@linutronix.de
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150320164951.GA25334@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 20 March 2015, Richard Cochran wrote:
> Instead of changing to ktime_t, just use timespec64 instead.  That
> way, each change will be a couple of lines per file.

This was the first idea, but it seems a bit silly when all the drivers
use a 64-bit nanosecond value just like ktime_t. While both of the
current users require a timespec at the moment, it's possible that
there would one day be a third user that actually can make sense of
a ktime_t, and then we'd avoid the expensive back-and-forth conversion.

For now, using ktime_t in the interface merely simplifies the drivers
by moving the conversion into the subsystem, but it is not any more
or less efficient than the previous method.

> > I do agree however that we should merge the entire series at once so
> > we end up with a reasonable state afterwards, and we only need the conditional
> > in order to have a bisectable git history.
> 
> It is still bisectable with one or two patches.

Of course, but it would be rather bad style.

	Arnd
