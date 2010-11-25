From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] hso: fix disable_net
Date: Thu, 25 Nov 2010 15:16:13 +0300
Message-ID: <4CEE538D.7050205@ru.mvista.com>
References: <1290627352.1739.19.camel@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, jhovold@gmail.com, pki@ex.com.pl,
	j.dumon@option.com
To: Filip Aben <f.aben@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56620 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866Ab0KYMSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:18:06 -0500
In-Reply-To: <1290627352.1739.19.camel@filip-linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-11-2010 22:35, Filip Aben wrote:

> The HSO driver incorrectly creates a serial device instead of a net
> device when disable_net is set. It shouldn't create anything for the
> network interface.

> Signed-off-by: Filip Aben <f.aben@option.com>
> ---

> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index b154a94..b05c235 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -2994,10 +2994,10 @@ static int hso_probe(struct usb_interface *interface,
>
>   	case HSO_INTF_BULK:
>   		/* It's a regular bulk interface */
> -		if (((port_spec&  HSO_PORT_MASK) == HSO_PORT_NETWORK)&&
> -		    !disable_net)
> +		if ((port_spec&  HSO_PORT_MASK) == HSO_PORT_NETWORK) {
> +		    if(!disable_net)

    Don't use spaces for indentation.

WBR, Sergei
