From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V9 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Fri, 14 Jan 2011 05:39:31 +0900
Message-ID: <AANLkTimHP1OsWauj6O566WgnxVTjMbNg2PK644QcT9Lq@mail.gmail.com>
References: <cover.1294917347.git.richard.cochran@omicron.at> <60566a54842bcf5974d55ed39f387c32ff9cf5cb.1294917348.git.richard.cochran@omicron.at>
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
In-Reply-To: <60566a54842bcf5974d55ed39f387c32ff9cf5cb.1294917348.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2011 at 8:32 PM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch adds a new mode bit into the timex structure. When set, the bit
> instructs the kernel to add the given time value to the current time.

The unix time is a nonlinear timescale and there's no way to predict
how many leap seconds will be inserted/deleted during the given time
interval.  So it is impossible to convert relative time to absolute
time and thus your patch is broken. (More specifically, the
timekeeping_inject_offset function is broken.)

My proposal: Limit the adjustable range of the offset so that leap
seconds will never occur more than once. (2147.5 seconds would be the
best choice. :-)
