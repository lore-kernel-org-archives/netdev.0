From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 2/2 v3] net/smsc911x: Add regulator support
Date: Fri, 28 Oct 2011 22:33:53 +0200
Message-ID: <20111028203353.GE23421@pengutronix.de>
References: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>, linux-omap@vger.kernel.org,
	Mike Frysinger <vapier@gentoo.org>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Linus Walleij <linus.walleij@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40099 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932754Ab1J1UeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 16:34:00 -0400
Content-Disposition: inline
In-Reply-To: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On Thu, Oct 27, 2011 at 02:48:11PM +0200, Linus Walleij wrote:
> From: Robert Marklund <robert.marklund@stericsson.com>
> 
> Add some basic regulator support for the power pins, as needed
> by the ST-Ericsson Snowball platform that powers up the SMSC911
> chip using an external regulator.
> 
> Platforms that use regulators and the smsc911x and have no defined
> regulator for the smsc911x and claim complete regulator
> constraints with no dummy regulators will need to provide it, for
> example using a fixed voltage regulator. It appears that this may
> affect (apart from Ux500 Snowball) possibly these archs/machines
> that from some grep:s appear to define both CONFIG_SMSC911X and
> CONFIG_REGULATOR:
> 
> - ARM Freescale mx3 and OMAP 2 plus, Raumfeld machines
> - Blackfin
> - Super-H
> 

...

>  
> +
> +/*
> + * Request or free resources, currently just regulators.
> + *
> + * The SMSC911x has two power pins: vddvario and vdd33a, in designs where
> + * these are not always-on we need to request regulators to be turned on
> + * before we can try to access the device registers.
> + */
> +static int smsc911x_request_free_resources(struct platform_device *pdev,
> +		bool request)

I had to look twice at this function name. First I thought "request the
free resources?", which other resources would you request if not the
free ones? I think it would be nicer to have two functions instead.
Just my 2 cents.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
