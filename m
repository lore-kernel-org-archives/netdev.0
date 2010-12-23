From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Thu, 23 Dec 2010 07:13:59 +0100
Message-ID: <20101223061359.GA7169@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
 <20101221075612.GA13626@riccoc20.at.omicron.at>
 <AANLkTimJd5pScKTiDxuYd-h+NevYbCusyvUAqmUDXe8h@mail.gmail.com>
 <1292970355.2618.76.camel@work-vm>
 <AANLkTimmTzH8+fSYmbajqZ+hU5Ps-UZaTp_1TYzjHB6P@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimmTzH8+fSYmbajqZ+hU5Ps-UZaTp_1TYzjHB6P-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 23, 2010 at 05:27:58AM +0900, Kuwahara,T. wrote:
> On Wed, Dec 22, 2010 at 7:25 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > I don't see why that would be better then adding a
> > clear new mode flag?
> 
> In short, time step is a special case of time slew.  Those are the same,
> only different in one parameter, as is shown in my previous post.
> That's why I said there's no need for adding a new mode.

Well, in addition to the objections raised by John, your suggested
implementation is also shortsighted. The field timex.constant is
copied into time_constant in some code paths. Obviously, this would be
a bad thing when timex.constant==-huge.

So, you need to clarify the interaction between ADJ_OFFSET,
ADJ_TIMECONST, ADJ_TAI, timex.constant, time_constant, and MAXTC.

If you would fully implement your idea, I expect it would become
obvious that it a bit of a hack, both in the kernel code and in the
user space interface. But, if you disagree, please just post a patch
with the complete implementation...

Thanks,
Richard
