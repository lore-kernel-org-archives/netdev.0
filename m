From: Filip Aben <f.aben@option.com>
Subject: Re: [PATCH] hso: remove setting of low_latency flag
Date: Thu, 17 Jun 2010 11:03:35 +0200
Message-ID: <1276765415.1532.5.camel@filip-linux>
References: <alpine.DEB.2.00.1006111100250.6812@filip-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:24824 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759467Ab0FQJDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 05:03:38 -0400
In-Reply-To: <alpine.DEB.2.00.1006111100250.6812@filip-linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Did the patch below get accepted or is there a problem with it ?
Haven't seen it appearing in any git trees so far.

Thanks,

Filip-

On Fri, 2010-06-11 at 11:17 +0200, f.aben@option.com wrote:
> This patch removes the setting of the low_latency flag. 
> tty_flip_buffer_push() is occasionally being called in irq context, which 
> causes a hang if the low_latency flag is set.
> Removing the low_latency flag only seems to impact the flush to ldisc, 
> which will now be put on a workqueue.
> 
> Signed-off-by: Filip Aben <f.aben@option.com>
> 
> ---
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 0a3c41f..4dd2351 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1334,7 +1334,6 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
>  	/* check for port already opened, if not set the termios */
>  	serial->open_count++;
>  	if (serial->open_count == 1) {
> -		tty->low_latency = 1;
>  		serial->rx_state = RX_IDLE;
>  		/* Force default termio settings */
>  		_hso_serial_set_termios(tty, NULL);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

