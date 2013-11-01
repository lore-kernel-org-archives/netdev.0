From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 17/24] net: cdc_ncm: use netif_* and dev_*
 instead of pr_*
Date: Fri, 01 Nov 2013 03:36:54 -0700
Message-ID: <1383302214.13084.6.camel@joe-AO722>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
	 <1383301021-16613-18-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0063.hostedemail.com ([216.40.44.63]:42162 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752160Ab3KAKgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 06:36:55 -0400
In-Reply-To: <1383301021-16613-18-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-01 at 11:16 +0100, Bj=F8rn Mork wrote:
> Take advantage of standard device name prefixing and
> netdevice msglvl control where possible.

Nice, thanks.

You did most all the multi-line statement
alignment perfectly but missed a couple.

Maybe in a follow-on patch.

> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
[]
> @@ -1031,17 +1035,13 @@ cdc_ncm_speed_change(struct usbnet *dev,
>  	 * device speed. Do print it instead.
>  	 */
>  	if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
> -		printk(KERN_INFO KBUILD_MODNAME
> -		       ": %s: %u mbit/s downlink "
> -		       "%u mbit/s uplink\n",
> -		       dev->net->name,
> +		netif_info(dev, link, dev->net,
> +		       "%u mbit/s downlink %u mbit/s uplink\n",
>  		       (unsigned int)(rx_speed / 1000000U),
>  		       (unsigned int)(tx_speed / 1000000U));
>  	} else {
> -		printk(KERN_INFO KBUILD_MODNAME
> -		       ": %s: %u kbit/s downlink "
> -		       "%u kbit/s uplink\n",
> -		       dev->net->name,
> +		netif_info(dev, link, dev->net,
> +		       "%u kbit/s downlink %u kbit/s uplink\n",
>  		       (unsigned int)(rx_speed / 1000U),
>  		       (unsigned int)(tx_speed / 1000U));
>  	}
