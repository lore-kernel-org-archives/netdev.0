From: Nish Aravamudan <nish.aravamudan@gmail.com>
Subject: Re: [RFT] skge: new syskonnect gigabit ethernet driver
Date: Wed, 19 Jan 2005 16:41:32 -0800
Message-ID: <29495f1d05011916414a82da64@mail.gmail.com>
References: <20050119135217.38fe5f05@dxpl.pdx.osdl.net>
	 <41EEF49F.5090504@pobox.com>
Reply-To: Nish Aravamudan <nish.aravamudan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262004AbVATAl4@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41EEF49F.5090504@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jan 2005 19:00:31 -0500, Jeff Garzik <jgarzik@pobox.com> wrote:
> Stephen Hemminger wrote:
> > This is the second public release of my new rewrite of the SysKonnect Gigabit
> > Ethernet driver.  This 0.3 version fixes bugs with link up/down and ethtool
> > phys_id support.  It adds ethtool support for interrupt coalescing and pause
> > parameters. Performance is good, I am able to get 941 Mbit/sec receiving
> > (TCP using iperf). But obviously, the driver is still experimental.
> >
> > This driver doesn't support Yukon2 (yet), and there is report of problem
> > with D-Link card (Yukon-EC).
> >
> > The patch should work on 2.6.8 or later, I am testing with 2.6.11-rc1.
> > Also available as download from http://developer.osdl.org/shemminge/skge

<snip>

> > +static int skge_phys_id(struct net_device *dev, u32 data)
> > +{
> > +     struct skge_port *skge = netdev_priv(dev);
> > +
> > +     if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
> > +             data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
> > +
> > +     /* start blinking */
> > +     skge->blink_on = 1;
> > +     mod_timer(&skge->led_blink, jiffies);
> > +
> > +     set_current_state(TASK_INTERRUPTIBLE);
> > +     schedule_timeout(data * HZ);
> > +     del_timer_sync(&skge->led_blink);

Please consider using msleep_interruptible(data * 1000) here. The same
substitution has worked in other drivers that have used the exact same
code.

Thanks,
Nish
