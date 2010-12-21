From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Tue, 21 Dec 2010 13:59:44 -0800
Message-ID: <1292968784.2618.51.camel@work-vm>
References: <cover.1292512461.git.richard.cochran@omicron.at>
	 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
	 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
	 <1292960224.2618.4.camel@work-vm>
	 <AANLkTikHV-qN73Zvvvxn76vtFFKG_VNTQhF3qpqTnOrE@mail.gmail.com>
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
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexander Gordeev <lasaine-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikHV-qN73Zvvvxn76vtFFKG_VNTQhF3qpqTnOrE-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-22 at 06:13 +0900, Kuwahara,T. wrote:
> On Wed, Dec 22, 2010 at 4:37 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > adjtimex is a linux specific interface, which is compatible but not
> > identical to the ntp specified interfaces. The ntp client code already
> > has Linux specific modifications, so I don't think we have to worry
> > about 0x40 specifically being reserved by the NTP client.
> 
> But struct timex is not linux-specific...

It is if you're compiling against linux's timex.h file. 

We already have a number of differences compared with BSD's timex mode
definitions:
We have ADJ_TICK: 0x4000, which is MOD_CLKB in FreeBSD.
We also have ADJ_OFFSET_SINGLESHOT and ADJ_OFFSET_SS_READ which allow
adjtimex act like the original ntp_adjtime.

The key bit is that we map the shared MOD_* definitions that the NTP
client uses to the linux specific ADJ_* values in the linux timex.h

However, your concern does bring up a good point: 0x40 is MOD_PPSMAX in
BSD, and we should at-least check to make sure that the PPS code that is
currently floating around on the lists and is in akpm's tree hasn't
already reserved that bit.

Rodolfo, Alexander: Any comments here?

thanks
-john
