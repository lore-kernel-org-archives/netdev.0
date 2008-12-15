From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 09/12] clocksource: allow usage independent of
	timekeeping.c
Date: Mon, 15 Dec 2008 17:45:00 +0100
Message-ID: <1229359500.18038.234.camel@ecld0pohly>
References: <1229352899-31330-1-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-2-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-3-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-4-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-5-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-6-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-7-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-8-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-9-git-send-email-patrick.ohly@intel.com>
	 <1229352899-31330-10-git-send-email-patrick.ohly@intel.com>
	 <1229358410.8699.13.camel@jstultz-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1229358410.8699.13.camel@jstultz-laptop>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-12-15 at 16:26 +0000, John Stultz wrote:
[cyclecounter/timecounter]
> Nice. The cyclecounter struct can work as a good base that I can shift
> the clocksource bits over to as I clean that up.
> 
> We will probably want to split this out down the road, but for now its
> small enough and related enough that I think its fine in the
> clocksource.h/c.
> 
> Also since Magnus has been working on it, does enable/disable accessors
> in the cyclecounter struct make sense for your hardware as well?

I don't think so. The usage model of the cyclecounter is that the
hardware is owned by someone who initializes and controls it, including
enable/disable. The abstract API with the read method is just there so
that common utility code can access the hardware in a uniform way.

For example, the igb driver owns and uses the NIC time register.
Disabling the NIC timer should be done together with disabling the NIC.
This is different from traditional clocksources which are independent
and controlled by the timing subsystem.

> Also the corner cases on overflows (how we manage the state, should
> reads be deferred for too long) will need to be addressed, but I guess
> we can solve that when it becomes an issue. Just to be clear: none of
> the hardware you're submitting this round has wrapping issues?

It has 64 bit registers, so there is indeed no wrapping issue.

> Otherwise,
> Acked-by: John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, will add that.

Can you (or someone else) also look at clocksync.[ch]? David wanted to
have that independently reviewed, too, before including it in
netdev-next.


--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
