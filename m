From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 3/3] RFC: net: smsc911x: add wake-up event interrupt
 support
Date: Mon, 11 Jul 2016 01:14:52 -0700
Message-ID: <20160711081451.GX28305@atomide.com>
References: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
 <1467968852-6175-3-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>,
	Sudeep Holla <sudeep.holla@arm.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	"Rafael J . Wysocki" <rjw@rjwysocki.net>,
	John Stultz <john.stultz@linaro.org>,
	linux-omap@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:57959 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030272AbcGKIO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 04:14:57 -0400
Content-Disposition: inline
In-Reply-To: <1467968852-6175-3-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Linus Walleij <linus.walleij@linaro.org> [160708 02:10]:
> The SMSC911x have a line out of the chip called "PME",
> Power Management Event. When connected to an asynchronous
> interrupt controller this is able to wake the system up
> from sleep in response to certain network events.

Cool, so far have not found any boards here with that
connected. Should be possible to solder that on at least
omap3-evm at some point though.

> +static irqreturn_t smsc911x_pme_irq_thread(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct smsc911x_data *pdata __maybe_unused = netdev_priv(dev);
> +
> +	SMSC_TRACE(pdata, pm, "wakeup event");
> +	/* This signal is active for 50 ms, wait for it to deassert */
> +	usleep_range(50000, 100000);
> +	return IRQ_HANDLED;
> +}

This probably adds an extra 50 ms latency before we wake up
the smsc911x driver. Maybe we can eventually come up with
some nice solution to that too. Anyways, no objections on
my side for this patch as it provides a nice GPIO wakeirq test
case that can be automated with just ping -c 1 :)

Regards,

Tony
