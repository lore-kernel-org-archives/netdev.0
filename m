From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 3/3] net: fec: add phy-reset-interval for device tree
 probe
Date: Tue, 26 Jun 2012 20:13:36 +0800
Message-ID: <20120626121334.GF8858@S2101-09.ap.freescale.net>
References: <1340700308-8315-1-git-send-email-shawn.guo@linaro.org>
 <1340700308-8315-4-git-send-email-shawn.guo@linaro.org>
 <2921547.BkALd1Y1Bk@flexo>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:57090
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754432Ab2FZMNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 08:13:36 -0400
Content-Disposition: inline
In-Reply-To: <2921547.BkALd1Y1Bk@flexo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 26, 2012 at 01:55:05PM +0200, Florian Fainelli wrote:
> > +	of_property_read_u32(np, "phy-reset-interval", &msec);
> >  	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
> >  	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
> >  	if (err) {
> >  		pr_debug("FEC: failed to get gpio phy-reset: %d\n", err);
> >  		return;
> >  	}
> > -	msleep(1);
> > +	msleep(msec);
> 
> You might want to check the value of the property here to make sure it is in 
> the msleep() acceptable range.
> 
Sounds good.  I think a sensible reset duration should be less one
second, so let's force 1000 ms to be the possible max one?

-- 
Regards,
Shawn
