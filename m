From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 22 Dec 2010 16:00:10 -0800
Message-ID: <1293062410.2404.186.camel@work-vm>
References: <cover.1292512461.git.richard.cochran@omicron.at>
	 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
	 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
	 <20101221075612.GA13626@riccoc20.at.omicron.at>
	 <AANLkTimJd5pScKTiDxuYd-h+NevYbCusyvUAqmUDXe8h@mail.gmail.com>
	 <1292970355.2618.76.camel@work-vm>
	 <AANLkTimmTzH8+fSYmbajqZ+hU5Ps-UZaTp_1TYzjHB6P@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTimmTzH8+fSYmbajqZ+hU5Ps-UZaTp_1TYzjHB6P-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-23 at 05:27 +0900, Kuwahara,T. wrote:
> On Wed, Dec 22, 2010 at 7:25 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > I don't see why that would be better then adding a
> > clear new mode flag?
> 
> In short, time step is a special case of time slew.  Those are the same,
> only different in one parameter, as is shown in my previous post.
> That's why I said there's no need for adding a new mode.

Sure, I get that a instantaneous offset adjustment could be represented
as a instantaneous slew of the same amount. But what is the benefit of
doing this? The ADJ_OFFSET isn't really a continuous function like you
describe. For instance, you can't slew time backwards. The amount you
can slow or speed up the clock is limited, so time will always increase.
So to have a magic value way outside the bound of normal operation that
does something special seems a bit obfuscated.

ADJ_SETOFFSET isn't slewing the clock. So I think its much clearer to
add a new mode, rather then to try to wedge the functionality into a
corner case of ADJ_OFFSET slewing just because one could mathematically
represent it the same way.

I see the cost of adding it as a special case as adding extra complexity
to an already complex subsystem. Doing things that make the code easier
to understand and read makes it more maintainable. And I don't see the
gain (other then saving a bit in the bit flag) to offset the complexity
of trying to squeeze this functionality into the ADJ_OFFSET mode.

thanks
-john
