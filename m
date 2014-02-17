From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCHv2] irtty-sir.c: Do not set_termios() on irtty_close()
Date: Mon, 17 Feb 2014 23:13:19 +0000
Message-ID: <20140217231319.5545dac1@alan.etchedpixels.co.uk>
References: <52FC87B6.4070001@gannert.se>
	<5302750C.6080407@gannert.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tommie Gannert <tommie@gannert.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5302750C.6080407@gannert.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> v2: Resend due to mail format issues. More Thunderbird settings applied.
> 
> I know very little of this code, and I'm not sure this is a good solution,
> so here's some background:

I wouldn't worry too much. I'm amazed the code even works these days.
It's incredibly bitrotted and doesn't use the tty layer properly (mind
you it never did)


> The effect of this is that /dev/ttyUSB* is still in use, and thus leaking
> at least dev nodes. This is a minimal patch that solves that oops.
> --- linux-3.12/drivers/net/irda/irtty-sir.c.orig	2014-02-12 21:36:46.132496089 +0000
> +++ linux-3.12/drivers/net/irda/irtty-sir.c	2014-02-12 21:57:21.635843884 +0000
> @@ -521,7 +521,6 @@ static void irtty_close(struct tty_struc
>  	sirdev_put_instance(priv->dev);
>  
>  	/* Stop tty */
> -	irtty_stop_receiver(tty, TRUE);
>  	clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
>  	if (tty->ops->stop)
>  		tty->ops->stop(tty);

This change looks correct to me. The three lines below your change are
amusing all incorrect and should probably also all be deleted.

Alan
