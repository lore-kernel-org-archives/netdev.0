From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] pl25a1_support
Date: Wed, 30 Mar 2011 15:31:36 +0400
Message-ID: <4D931498.9000505@ru.mvista.com>
References: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Brownell <david-b@pacbell.net>
To: Simon Wood <simon@mungewell.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301456667-1648-1-git-send-email-simon@mungewell.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 30-03-2011 7:44, Simon Wood wrote:

> Adds support for 'Windows Easy Transfer' cables based around the
> Prolific PL-25A1 chip (includes Belkin F5U258&  F5U279)

> Patch originally suggested by David Brownell here:
> http://www.mail-archive.com/netdev@vger.kernel.org/msg61926.html

> Modified to work with latest kernel, tested with F5U279.
>
> Signed-off-by: Simon Wood<simon@mungewell.org>

[...]

> diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
> index 08ad269..a20afac 100644
> --- a/drivers/net/usb/plusb.c
> +++ b/drivers/net/usb/plusb.c
[...]
> @@ -89,13 +97,17 @@ static int pl_reset(struct usbnet *dev)
>   	/* some units seem to need this reset, others reject it utterly.
>   	 * FIXME be more like "naplink" or windows drivers.
>   	 */
> -	(void) pl_set_QuickLink_features(dev,
> +	int     status;
> +
> +        status = pl_set_QuickLink_features(dev,

    This line is indented with spaces ISO tab.

> +	if (status != 0 && netif_msg_probe(dev))
> +		netif_dbg(dev, link, dev->net, "pl_reset --> %d\n", status);
>  	return 0;
>  }

    Also, the above change doesn't seem to be related to the declared purpose 
of the patch, so seems to be a matter of another patch...

> @@ -134,16 +153,16 @@ static struct usb_driver plusb_driver = {
>
>   static int __init plusb_init(void)
>   {
> - 	return usb_register(&plusb_driver);
> +	return usb_register(&plusb_driver);
>   }
>   module_init(plusb_init);
>
>   static void __exit plusb_exit(void)
>   {
> - 	usb_deregister(&plusb_driver);
> +	usb_deregister(&plusb_driver);
>   }

    Likewise, the whitespace fixes should be a matgter of a separate patch...

WBR, Sergei
