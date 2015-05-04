From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 4/8] net: mv643xx_eth: Handle Ethernet
 switches as PHY devices
Date: Sun, 03 May 2015 22:06:33 -0400 (EDT)
Message-ID: <20150503.220633.467179430594919041.davem@davemloft.net>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
	<1430359064-23454-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbEDCGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 22:06:36 -0400
In-Reply-To: <1430359064-23454-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 29 Apr 2015 18:57:40 -0700

> @@ -2321,7 +2321,7 @@ static void port_start(struct mv643xx_eth_private *mp)
>  	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
>  
>  	pscr |= DO_NOT_FORCE_LINK_FAIL;
> -	if (mp->phy == NULL)
> +	if (mp->phy == NULL || (mp->phy && phy_is_ethswitch(mp->phy)))
>  		pscr |= FORCE_LINK_PASS;

Maybe it looks clearer to you in this form, but the C language
guarentees that:

	if (!ptr || ptr->foo)

will not perform a NULL pointer deref.

So I'm pretty sure you could simply this statement to:

	if (mp->phy == NULL || phy_is_ethswitch(mp->phy))
