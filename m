From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] RFC: net: smsc911x: add wake-up event interrupt
 support
Date: Fri, 15 Jul 2016 12:13:34 -0700
Message-ID: <578935DE.8090104@gmail.com>
References: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
 <1467968852-6175-3-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>,
	Sudeep Holla <sudeep.holla@arm.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Tony Lindgren <tony@atomide.com>,
	"Rafael J . Wysocki" <rjw@rjwysocki.net>,
	John Stultz <john.stultz@linaro.org>
To: Linus Walleij <linus.walleij@linaro.org>, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36530 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbcGOTNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 15:13:38 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so3148844pab.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 12:13:38 -0700 (PDT)
In-Reply-To: <1467968852-6175-3-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 02:07 AM, Linus Walleij wrote:
> +static irqreturn_t smsc911x_pme_irq_thread(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct smsc911x_data *pdata __maybe_unused = netdev_priv(dev);
> +
> +	SMSC_TRACE(pdata, pm, "wakeup event");
> +	/* This signal is active for 50 ms, wait for it to deassert */
> +	usleep_range(50000, 100000);

Should not you have a call to pm_wakeup_event() such that this probably
gets accounted for as a wake-up event in /sys/*?
-- 
Florian
