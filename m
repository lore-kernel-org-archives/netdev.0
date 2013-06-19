From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: usb_8dev: unregister netdev before free()ing
Date: Wed, 19 Jun 2013 18:29:12 +0200
Message-ID: <51C1DC58.2040705@hartkopp.net>
References: <1371625369-26368-1-git-send-email-mkl@pengutronix.de> <1371625369-26368-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	davem@davemloft.net, stable@kernel.org,
	=?ISO-8859-1?Q?Bernd_Krumb=F6c?= =?ISO-8859-1?Q?k?=
	<krumboeck@universalnet.at>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1371625369-26368-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc,

the usb_8dev driver was introduced in Linux 3.9 and therefore this reasonable
patch should be queued up for linux-3.9.y stable too.

Regards,
Oliver


On 19.06.2013 09:02, Marc Kleine-Budde wrote:
> The usb_8dev hardware has problems on some xhci USB hosts. The driver fails to
> read the firmware revision in the probe function. This leads to the following
> Oops:
> 
>     [ 3356.635912] kernel BUG at net/core/dev.c:5701!
> 
> The driver tries to free the netdev, which has already been registered, without
> unregistering it.
> 
> This patch fixes the problem by unregistering the netdev in the error path.
> 
> Reported-by: Michael Olbrich <m.olbrich@pengutronix.de>
> Reviewed-by: Bernd Krumboeck <krumboeck@universalnet.at>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>  drivers/net/can/usb/usb_8dev.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/can/usb/usb_8dev.c b/drivers/net/can/usb/usb_8dev.c
> index 6e15ef0..cbd388e 100644
> --- a/drivers/net/can/usb/usb_8dev.c
> +++ b/drivers/net/can/usb/usb_8dev.c
> @@ -977,7 +977,7 @@ static int usb_8dev_probe(struct usb_interface *intf,
>  	err = usb_8dev_cmd_version(priv, &version);
>  	if (err) {
>  		netdev_err(netdev, "can't get firmware version\n");
> -		goto cleanup_cmd_msg_buffer;
> +		goto cleanup_unregister_candev;
>  	} else {
>  		netdev_info(netdev,
>  			 "firmware: %d.%d, hardware: %d.%d\n",
> @@ -989,6 +989,9 @@ static int usb_8dev_probe(struct usb_interface *intf,
>  
>  	return 0;
>  
> +cleanup_unregister_candev:
> +	unregister_netdev(priv->netdev);
> +
>  cleanup_cmd_msg_buffer:
>  	kfree(priv->cmd_msg_buffer);
>  
> 

