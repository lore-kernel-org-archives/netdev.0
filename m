From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] asix - Add support for LyconSys FiberGecko
Date: Thu, 07 Aug 2014 20:33:53 +0400
Message-ID: <53E3AA71.5070201@cogentembedded.com>
References: <1407426826-11335-1-git-send-email-dhollis@davehollis.com> <1407426826-11335-2-git-send-email-dhollis@davehollis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Hollis <dhollis@davehollis.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:58638 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238AbaHGQd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 12:33:57 -0400
Received: by mail-la0-f52.google.com with SMTP id b17so2612914lan.25
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 09:33:56 -0700 (PDT)
In-Reply-To: <1407426826-11335-2-git-send-email-dhollis@davehollis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/07/2014 07:53 PM, David Hollis wrote:

> Reported-by: Sven Kreiensen <s.kreiensen@lyconsys.com>
> Signed-off-by: David Hollis <dhollis@davehollis.com>

> ---
>   drivers/net/usb/asix_devices.c | 25 ++++++++++++++++++++++++-
>   1 file changed, 24 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
> index 5d19409..d09f2ea 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
[...]
> @@ -648,6 +648,12 @@ static int ax88178_reset(struct usbnet *dev)
>   	asix_sw_reset(dev, 0);
>   	msleep(150);
>
> +	/* LyconSys FiberGecko: Turn on PHY */
> +	if (dev->driver_info->flags == 0x20061201) {

    Hm, don't use magic values please. Doesn't the flags get assigned a 
combination  of FLAG_* values below? Or you mixed up 'flags' and 'data' fields?

> +		/* Power on Phy: set gpio2=high */
> +		asix_write_gpio(dev, AX_GPIO_GPO2EN | AX_GPIO_GPO_2, 50);
> +	}
> +
>   	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
>   	msleep(150);
>
> @@ -946,6 +952,19 @@ static const struct driver_info hg20f9_info = {
>   	.data = FLAG_EEPROM_MAC,
>   };
>
> +static const struct driver_info lyconsys_fibergecko100_info = {
> +	.description = "LyconSys FiberGecko 100 USB 2.0 to Ethernet Adapter",
> +	.bind = ax88178_bind,
> +	.status = asix_status,
> +	.link_reset = ax88178_link_reset,
> +	.reset = ax88178_link_reset,
> +	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |
> +		 FLAG_MULTI_PACKET,
> +	.rx_fixup =	asix_rx_fixup_common,
> +	.tx_fixup =	asix_tx_fixup,

    Hm, why this sudden change of the initializer style?

> +	.data = 0x20061201,
> +};
> +

WBR, Sergei
