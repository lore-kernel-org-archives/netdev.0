From: Kurt Van Dijck <dev.kurt@vandijck-laurijssen.be>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Mon, 8 Aug 2016 15:06:33 +0200
Message-ID: <20160808130633.GC12298@airbook.newtec.eu>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
 <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andreas Werner <andreas.werner@men.de>, mkl@pengutronix.de,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	jthumshirn@suse.de, andy@wernerandy.de, michael.miehling@men.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Original message ---
> Date:	Mon, 8 Aug 2016 14:28:39 +0200
> From: Wolfgang Grandegger <wg@grandegger.com>
> 
[...]
> >>>+
> >>>+	if (!(cf->can_id & CAN_RTR_FLAG)) {
> >>>+		writel(data[0], &cf_buf->data[0]);
> >>>+		writel(data[1], &cf_buf->data[1]);
> >>
> >>Why do you not check cf->can_dlc here as well. And is the extra copy
> >>necessary.
> >>
> >
> >Yes, I agree with you. The extra copy could be also avoided.
> >
> >>>+
> >>>+		stats->tx_bytes += cf->can_dlc;
> >>>+	}
> >>
> >>If I look to other drivers, they write the data even in case of RTR.
> >>
> >
> >But why?
> >
> >A RTR does not have any data, therefore there is no need to write the data.
> >Only the length is required as the request size.
> 
> Yes; I'm wondering as well.
> 
> >
> >If there is a reason behind writing the data of a RTR frame, I can
> >change that, but for now there is no reason.
> 
> Yep.

I _think_ that copying the data without checking the RTR bit clearly
avoids a condition and might produce faster code on some machines.
In any case, it reads easier.
I'm not sure how that interacts with caches etc etc.

On the other hand, giving unused data is a bad habit that may reveal
security information on some places, so better avoid it.

Kurt
