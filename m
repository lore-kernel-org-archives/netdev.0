From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 22 Dec 2010 05:57:02 +0900
Message-ID: <AANLkTimJd5pScKTiDxuYd-h+NevYbCusyvUAqmUDXe8h@mail.gmail.com>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com> <20101221075612.GA13626@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101221075612.GA13626-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2010 at 4:56 PM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Can you please elaborate?

The timex.constant is defined as equal to the binary logarithm of the
reciprocal of
the natural frequency minus SHIFT_PLL.  In other words, the following
equation holds:

	log2(natural frequency) + time_constant + SHIFT_PLL = 0,

which means that decreasing time_constant increases natural frequency
exponentially.
And since a larger natural frequency gives a smaller settling time, a
sufficiently
large negative time_constant results in immediate time step, at least in theory.

> I don't see any way to use timex.constant with ADJ_OFFSET in order to
> correct a time offset.

How about this?

if (txc->modes & ADJ_OFFSET) {
	if (txc->constant == INT32_MIN) {
		/* step time */
	} else {
		/* slew time */
	}
}

> The 'time_constant' in kernel/time/ntp.c is
> restricted to the interval [0..MAXTC], and MAXTC is 10 in timex.h.

Then let's just ignore the restriction.  (It's possible by setting the
timex.constant
without setting the ADJ_TIMECONST flag.)

That said, I'm somehow against the idea of using the adjtimex syscall
for that purpose.
