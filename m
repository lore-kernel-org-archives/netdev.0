From: John Stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Fri, 27 Aug 2010 13:56:08 -0700
Message-ID: <1282942568.2268.60.camel@jstultz-laptop>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	 <1282594899.3111.358.camel@localhost.localdomain>
	 <20100827110855.GA11657@riccoc20.at.omicron.at>
	 <201008271403.41949.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201008271403.41949.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-08-27 at 14:03 +0200, Arnd Bergmann wrote:
> On Friday 27 August 2010, Richard Cochran wrote:
> > On Mon, Aug 23, 2010 at 01:21:39PM -0700, john stultz wrote:
> > > On Thu, 2010-08-19 at 17:38 +0200, Richard Cochran wrote:
> > > > On Thu, Aug 19, 2010 at 02:28:04PM +0200, Arnd Bergmann wrote:
> > > > > Have you considered passing a struct timex instead of ppb and ts?
> > > > 
> > > > Yes, but the timex is not suitable, IMHO.
> > > 
> > > Could you expand on this?
> > 
> > We need to able to specify that the call is for a PTP clock. We could
> > add that to the modes flag, like this:
> > 
> > /*timex.h*/
> > #define ADJ_PTP_0 0x10000
> > #define ADJ_PTP_1 0x20000
> > #define ADJ_PTP_2 0x30000
> > #define ADJ_PTP_3 0x40000
> >
> > I can live with this, if everyone else can, too.
> 
> My suggestion was actually to have a new syscall with the existing
> structure, and pass a clockid_t value to it, similar to your
> sys_clock_adjtime(), not change the actual sys_adjtime syscall.
>   
> > > Could we not add a adjustment mode ADJ_SETOFFSET or something that would
> > > provide the instantaneous offset correction?
> > 
> > Yes, but we would also need to add a struct timespec to the struct
> > timex, in order to get nanosecond resolution. I think it would be
> > possible to do in the padding at the end?
> 
> Yes, that's exactly what the padding is for. Instead of timespec, you can
> probably have a extra values for replacing the existing ppm values with
> ppb values.

Right, although the ppm/ppb issue shouldn't be a problem as the timex
allows for much finer then ppb resolution changes.

The only adjustment to the adjtimex/timex interface that may be needed
is the ability to set the time by an offset (ie: ADJ_SETOFFSET), rather
then slewing the offset in (ADJ_OFFSET, or ADJ_OFFSET_SINGLESHOT).

This avoids the calc offset, gettime(&now), settime(now+offset) method
where any latency between the gettime and settime adds to the error.

thanks
-john




thanks
-john
