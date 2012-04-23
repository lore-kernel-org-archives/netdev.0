From: Stephane Fillod <fillods@users.sf.net>
Subject: Re: [PATCH v2] smsc95xx: mark link down on startup and let PHY
 interrupt deal with carrier changes
Date: Mon, 23 Apr 2012 21:43:39 +0200
Message-ID: <20120423194339.GS5277@charybde.local>
References: <1335189920-31062-1-git-send-email-paolo.pisati@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org
To: Paolo Pisati <paolo.pisati@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.services.sfr.fr ([93.17.128.2]:7230 "EHLO
	smtp21.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab2DWTnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 15:43:41 -0400
Content-Disposition: inline
In-Reply-To: <1335189920-31062-1-git-send-email-paolo.pisati@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lun, Apr 23, 2012, Paolo Pisati skribis:
> Without this patch sysfs reports the cable as present
> 
> flag@flag-desktop:~$ cat /sys/class/net/eth0/carrier
> 1
> 
> while it's not:
> 
> flag@flag-desktop:~$ sudo mii-tool eth0
> eth0: no link
> 
> Tested on my Beagle XM.
> 
> v2: added mantainer to the list of recipient

His e-mail address has changed, but somehow it has not been updated yet
in MAINTAINERS directory:  steve.glendinning () shawell.net

> Signed-off-by: Paolo Pisati <paolo.pisati@canonical.com>
> ---
>  drivers/net/usb/smsc95xx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 3444514..93d3252 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1192,7 +1192,7 @@ static const struct driver_info smsc95xx_info = {
>  	.rx_fixup	= smsc95xx_rx_fixup,
>  	.tx_fixup	= smsc95xx_tx_fixup,
>  	.status		= smsc95xx_status,
> -	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
> +	.flags		= FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
>  };
>  
>  static const struct usb_device_id products[] = {

Tested this fix successfuly on elder brother smsc75xx, on top of
another patch yet-to-submit to fix smsc75xx's MDIO access.
