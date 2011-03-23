From: Andy Green <andy@warmcat.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 17:04:48 +0000
Message-ID: <4D8A2830.6020706@linaro.org>
References: <4D79F068.2080009@linaro.org> <201103231712.06184.arnd@arndb.de> <20110323162251.GA9367@kroah.com> <201103231756.39849.arnd@arndb.de>
Reply-To: andy.green@linaro.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	Linux USB list <linux-usb@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	broonie@opensource.wolfsonmicro.com, roger.quadros@nokia.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37791 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754235Ab1CWREx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 13:04:53 -0400
In-Reply-To: <201103231756.39849.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/2011 04:56 PM, Somebody in the thread at some point said:

> The approach taken here is to flag whether a device might be a
> point-to-point link with the new FLAG_PTP setting in the usbnet
> driver_info. A driver can set both FLAG_PTP and FLAG_ETHER if
> it is not sure (e.g. cdc_ether), or just one of the two.
> The usbnet framework only looks at the MAC address for device
> naming if both flags are set, otherwise it trusts the flag.

> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index bc86f4b..c98d3a7 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1231,7 +1231,7 @@ static const struct driver_info smsc95xx_info = {

> -	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
> +	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_REALLY_ETHER,

>   		if ((dev->driver_info->flags&  FLAG_ETHER) != 0&&
> +		    ((dev->driver_info->flags&  FLAG_PTP) == 0 ||
> +		     (net->dev_addr [0]&  0x02) == 0))
>   			strcpy (net->name, "eth%d");

So it just takes the approach that all smsc95xx are going to be eth%d? 
Sounds good to me.

-Andy
