From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] W5300: Add WIZnet W5300 Ethernet driver
Date: Tue, 8 Nov 2011 20:06:58 +0000
Message-ID: <1320782818.2799.62.camel@bwh-desktop>
References: <1320676661-19138-1-git-send-email-kth3321@gmail.com>
	 <1320779368.2799.55.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <suhwan@wiznet.co.kr>,
	<bongbong@wiznet.co.kr>
To: Taehun Kim <kth3321@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320779368.2799.55.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-08 at 19:09 +0000, Ben Hutchings wrote:
> On Mon, 2011-11-07 at 23:37 +0900, Taehun Kim wrote: 
[...]
> > +/* Default MAC address. */
> > +static __initdata u8 w5300_defmac[6] = {0x00, 0x08, 0xDC, 0xA0, 0x00, 0x01};
> 
> This is not suitable as a default MAC address.

Really you mustn't use a fixed default at all.

[...]
> > +/* Interrupt Handler(ISR) */
> > +static irqreturn_t wiz_interrupt(int irq, void *dev_instance)
> > +{
> > +	struct net_device *dev = dev_instance;
> > +	struct wiz_private *wp = netdev_priv(dev);
> > +	int timeout = 100;
> > +	u16 isr, ssr;
> > +	int s;
> > +
> > +	isr = w5300_read(wp, IR);
> > +
> > +	/* Completing all interrupts at a time. */
> > +	while (isr && timeout--) {
> 
> Why would you need to repeat this?  You disable the interrupt 
[...]

I'm not sure what I was starting to say there.

But I really don't see any justification for this loop.  Perhaps it's
left over from a non-NAPI implementation?  Just acknowledge the
interrupt, schedule NAPI as appropriate, and let the kernel call the
interrupt handler again if another interrupt is raised.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
