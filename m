From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 2/2] cdc-phonet: autoconfigure Phonet address
Date: Wed, 09 Sep 2009 12:24:10 +0200
Message-ID: <1252491850.8931.28.camel@violet>
References: <1252490406-27951-1-git-send-email-remi@remlab.net>
	 <1252490406-27951-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43765 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbZIIKYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 06:24:12 -0400
In-Reply-To: <1252490406-27951-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

>  drivers/net/usb/cdc-phonet.c |   15 +++++++++++++++
>  include/linux/phonet.h       |    3 +++
>  2 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
> index 0ca5916..97e54d9 100644
> --- a/drivers/net/usb/cdc-phonet.c
> +++ b/drivers/net/usb/cdc-phonet.c
> @@ -27,6 +27,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/if_arp.h>
>  #include <linux/if_phonet.h>
> +#include <linux/phonet.h>
>  
>  #define PN_MEDIA_USB	0x1B
>  
> @@ -256,6 +257,19 @@ static int usbpn_close(struct net_device *dev)
>  	return usb_set_interface(pnd->usb, num, !pnd->active_setting);
>  }
>  
> +static int usbpn_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> +{
> +	struct if_phonet_req *req = (struct if_phonet_req *)ifr;
> +
> +	switch (cmd) {
> +	case SIOCPNGAUTOCONF:
> +		req->ifr_phonet_autoconf.device = PN_DEV_PC;
> +		printk(KERN_CRIT"device is PN_DEV_PC\n");
> +		return 0;
> +	}
> +	return -ENOIOCTLCMD;
> +}
> +

am I understanding this correctly, that even for the USB ones we still
have to execute that ioctl() and can not just auto configure them all
the time? For the USB ones, I would expect to should plug them in and
they are getting configured right away.

Regards

Marcel


