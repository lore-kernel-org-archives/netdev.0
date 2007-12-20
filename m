From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/niu: Support for Marvell PHY
Date: Thu, 20 Dec 2007 15:25:03 -0800 (PST)
Message-ID: <20071220.152503.263532731.davem@davemloft.net>
References: <1197993838.26679.64.camel@mlindner-lin.skd.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752788AbXLTXZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:25:04 -0500
In-Reply-To: <1197993838.26679.64.camel@mlindner-lin.skd.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirko Lindner <mlindner@marvell.com>
Date: Tue, 18 Dec 2007 17:03:58 +0100

> +static int xcvr_init_10g_mrvl88x2011(struct niu *np)
> +{
> +	int err;
> +
> +	/* Set LED functions */
> +	mrvl88x2011_led_blink_rate(np, 2);
> +	mrvl88x2011_act_led(np, 0);	/* led activity */
> +
> +	err = mdio_read(np, np->phy_addr, 3, 0x8300);
> +	if (err < 0) {
> +		return(err);
> +	}
> +
> +	err |= 0x0001;
> +
> +	err = mdio_write(np, np->phy_addr, 3, 0x8300, err);
> +	if (err < 0) {
> +		return(err);
> +	}
> +
> +	/* Enable PMD */
> +	err = mdio_write(np, np->phy_addr, 1, 0x0009, 0);
> +	
> +	return (err);
> +}
> +

This code doesn't handle putting the PHY into loopback more etc. like
the BCM8704 chip initialization does.

Please also fully document the registers using defines in the niu.h
header file as is already done for the BCM8704 registers.  Magic
constants are not allowed.

I'd like this Marvell PHY chip to be documented so that, just like the
BCM8704, someone can look at the driver and understand how the chip
works and thus make bug fixes and changes.
