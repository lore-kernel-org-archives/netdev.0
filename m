From: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH V8 12/13] ptp: Added a clock driver for the IXP46x.
Date: Sat, 08 Jan 2011 17:25:36 +0100
Message-ID: <m3r5cnuzun.fsf@intrepid.localdomain>
References: <cover.1293820862.git.richard.cochran@omicron.at>
	<8151196c018776704df34748f333bdb159497d0b.1293820862.git.richard.cochran@omicron.at>
	<m3ei8plpa0.fsf@intrepid.localdomain>
	<20110107170752.GB8666@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110107170752.GB8666-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org> (Richard Cochran's
	message of "Fri, 7 Jan 2011 18:07:52 +0100")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> The time stamp code clones the skb, but the LE version frees the skb
> too early. Perhaps we can move that dev_kfree_skb(skb) in the LE case
> to be the last statement in eth_xmit(). What do you think?

I think so. Or something similar.

> Do you mean, you don't like the constant on the left hand side?

Yes.

> Is that prohibited by CodingStyle or similar?

I don't think so. It's just a personal taste. I think it's based on
things learned in primary school, they teach to write (comparisons)
X = 4 instead of the other way around, and my brain seems to shock
a bit on the opposite.

> I got into the habit of writing it that way to prevent a typo like:
>
> 	if (irq = NO_IRQ)

I see. Unfortunately it doesn't prevent typos like this when the right
side isn't a constant. Anyway gcc warns about them, even when both sides
are variable.

>> Also I don't like the ixp_read/ixp_write() trivial macros. Why not
>> simply call __raw_readl() and __raw_writel()?
>
> Well, I have had the experience back in 2.4 days of having my drivers
> ruined by the changing IO macros in the kernel. The wrappers are
> supposed to help if that ever happens again. Seeing *two* leading
> underscores in the macro names certainly makes me nervous.

Well, these two underscores mainly mean it's arch-dependent, but so are
the ixp4xx drivers. Using the __raw_read* directly is the preferred
method (or, perhaps, in such case, it's the only way).

Actually, I was thinking about changing the macros some time ago, and it
may eventually happen. But we'll fix all the code using them then.
-- 
Krzysztof Halasa
