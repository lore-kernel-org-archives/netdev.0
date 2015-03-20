From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces with "ktime_t" type
Date: Fri, 20 Mar 2015 14:43:42 +0100
Message-ID: <201503201443.42672.arnd@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org> <CAMz4kuKyDFCqd-LfoSKJf+tkXdzzLwtPJdp-nF6NbKU8W5HHpQ@mail.gmail.com> <20150320062603.GC4417@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Baolin Wang <baolin.wang@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.com>,
	tglx@linutronix.de
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150320062603.GC4417@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 20 March 2015, Richard Cochran wrote:
> On Fri, Mar 20, 2015 at 09:54:05AM +0800, Baolin Wang wrote:
> > Next patch series will contain all of the drivers which need to be changed.
> > But i think the conditional in ptp_clock.c can still in there.
> 
> Why?
> 
> > Because our plan is once all the drivers are converted, i will remove the
> > conditional, along with the original function pointer.
> > Is that OK? Thanks!
> 
> I want to avoid a patch series that introduces something, only to
> remove it later on.  Sometimes you have to do that way for a complex
> transformation, but this case is rather simple.
> 
> You can change the gettime signature in one patch, and the settime in
> a second patch.

We normally try to avoid doing those global API changes across many drivers
that are maintained by different people. Introducing the new API first
is the easiest way to get the per-driver patches reviewed individually
by the respective maintainers.

Doing gettime separately from settime would be rather silly here, so trying
to avoid the conditional would mean doing a single large patch across all
drivers.

I do agree however that we should merge the entire series at once so
we end up with a reasonable state afterwards, and we only need the conditional
in order to have a bisectable git history.

	Arnd
