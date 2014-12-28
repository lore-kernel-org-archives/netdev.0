From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH v2 3/4] can: kvaser_usb: Don't send a RESET_CHIP for
 non-existing channels
Date: Sun, 28 Dec 2014 22:54:05 +0100
Message-ID: <20141228215405.GC2548@thinkoso.home>
References: <20141223154654.GB6460@vivalin-002>
 <20141224235644.GA3778@vivalin-002>
 <20141224235954.GA24302@vivalin-002>
 <20141225000256.GB24302@vivalin-002>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:49780 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbaL1Vxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 16:53:41 -0500
Content-Disposition: inline
In-Reply-To: <20141225000256.GB24302@vivalin-002>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 25, 2014 at 02:02:56AM +0200, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> "Someone reported me that recent leaf firmwares go in trouble when
> you send a command for a channel that does not exist. Instead ...
> you can move the reset command to kvaser_usb_init_one() function."

Please adapt the commit log message as follows:
Recent Leaf firmware versions (>= 3.1.557) do not allow to send commands for
non-existing channels. If a command is send for a non-existing channel,
the firmware crashes.

And you can add:
Reported-by: Christopher Storah <Christopher.Storah@invetech.com.au>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>

Kr,

Olivier

> 
> Suggested-by: Olivier Sobrie <olivier@sobrie.be>
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> ---
>  drivers/net/can/usb/kvaser_usb.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> index 598e251..2791501 100644
> --- a/drivers/net/can/usb/kvaser_usb.c
> +++ b/drivers/net/can/usb/kvaser_usb.c
> @@ -1505,6 +1505,10 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
>  	struct kvaser_usb_net_priv *priv;
>  	int i, err;
>  
> +	err = kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, channel);
> +	if (err)
> +		return err;
> +
>  	netdev = alloc_candev(sizeof(*priv), MAX_TX_URBS);
>  	if (!netdev) {
>  		dev_err(&intf->dev, "Cannot alloc candev\n");
> @@ -1609,9 +1613,6 @@ static int kvaser_usb_probe(struct usb_interface *intf,
>  
>  	usb_set_intfdata(intf, dev);
>  
> -	for (i = 0; i < MAX_NET_DEVICES; i++)
> -		kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, i);
> -
>  	err = kvaser_usb_get_software_info(dev);
>  	if (err) {
>  		dev_err(&intf->dev,
