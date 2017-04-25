From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: hso: fix module unloading
Date: Tue, 25 Apr 2017 12:04:59 +0200
Message-ID: <20170425100459.GM2823@localhost>
References: <1493061519-15785-1-git-send-email-andreas@kemnade.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, joe@perches.com, peter@hurleysoftware.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Discussions about the Letux Kernel
        <letux-kernel@openphoenux.org>
To: Andreas Kemnade <andreas@kemnade.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35816 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031145AbdDYKFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 06:05:11 -0400
Content-Disposition: inline
In-Reply-To: <1493061519-15785-1-git-send-email-andreas@kemnade.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 09:18:39PM +0200, Andreas Kemnade wrote:
> keep tty driver until usb driver is unregistered
> rmmod hso
> produces traces like this without that:

Yeah, a blatant use-after-free.

> Signed-off-by: Andreas Kemnade <andreas@kemnade.info>

Reviewed-by: Johan Hovold <johan@kernel.org>

> ---
>  drivers/net/usb/hso.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 2e66340..b75e23f 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -3293,9 +3293,9 @@ static void __exit hso_exit(void)
>  	pr_info("unloaded\n");
>  
>  	tty_unregister_driver(tty_drv);
> -	put_tty_driver(tty_drv);
>  	/* deregister the usb driver */
>  	usb_deregister(&hso_driver);
> +	put_tty_driver(tty_drv);
>  }
>  
>  /* Module definitions */

Thanks,
Johan
